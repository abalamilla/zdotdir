-- Workday apps: open Slack and Teams (plus Roar on Fridays) at 07:00 and quit Slack and
-- Teams at 17:00, Monday to Friday. Terms are defined in GLOSSARY.md.
--
-- One check runs every minute, on wake and on unlock, so a run missed while the Mac
-- slept happens as a catch-up run, but only inside its window: open before 17:00,
-- close from 17:00 to 23:59. A last-<run> file marks a run done for the day, so config
-- reloads and repeated wakes never repeat it.
--
-- Paused dates are written by the workday-apps shell function (env/functions/workday-apps)
-- and read at every check.
--
-- Manual runs: hyper+O opens and hyper+C quits right away (bound in init.lua). They skip
-- every guard and the dialog, log "(manual)" and leave the done markers alone.

local M = {}

local HOME = os.getenv("HOME")
local STATE_DIR = HOME .. "/.local/state/workday-apps"
local LOG = HOME .. "/Library/Logs/workday-apps.log"

local OPEN_AT = "07:00"
local CLOSE_AT = "17:00"
local CLOSE_UNTIL = "23:59"
local SNOOZE_MINUTES = 10
local DIALOG_SECONDS = 120
local LATE_MINUTES = 5 -- a run this late is a catch-up run and shows an on-screen alert
local EMPTY_SECONDS = 120 -- app lookups can come back empty for a moment, so "nothing running" must last this long

-- Paths only: bundle IDs are read from each app's Info.plist at run time, because they
-- change (Teams went from com.microsoft.teams to com.microsoft.teams2).
local SLACK = { name = "Slack", path = HOME .. "/Applications/Slack.app" }
local TEAMS = { name = "Microsoft Teams", path = "/Applications/Microsoft Teams.app" }
local ROAR = { name = "Roar", path = HOME .. "/Applications/Chrome Apps.localized/rOarXMarcel.app" }
local OPEN_APPS = { SLACK, TEAMS }
local CLOSE_APPS = { SLACK, TEAMS }

local closing = false -- a close dialog is up or snoozed
local loggedPause = {} -- dates already logged as paused in this config load
local emptySince = nil -- { date, time } of the first close check that found no app running

local function minutesOf(hm)
	local h, m = hm:match("(%d+):(%d+)")
	return tonumber(h) * 60 + tonumber(m)
end

local function today()
	return os.date("%Y-%m-%d")
end

local function nowMinutes()
	return minutesOf(os.date("%H:%M"))
end

local function readFile(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local s = f:read("a")
	f:close()
	return s
end

local function log(line)
	local f = io.open(LOG, "a")
	if f then
		f:write(os.date("%Y-%m-%d %H:%M ") .. line .. "\n")
		f:close()
	end
end

-- hs.alert, not hs.notify: it needs no notification permission and no Focus mode hides it.
local function announce(text)
	hs.alert.show("Workday apps " .. text, 5)
end

local function isPaused(date)
	local s = readFile(STATE_DIR .. "/paused-dates")
	for line in (s or ""):gmatch("[^\n]+") do
		if line == date then
			return true
		end
	end
	return false
end

local function doneToday(run)
	local s = readFile(STATE_DIR .. "/last-" .. run)
	return s ~= nil and s:sub(1, 10) == today()
end

local function markDone(run, result)
	os.execute('/bin/mkdir -p "' .. STATE_DIR .. '"')
	local f = io.open(STATE_DIR .. "/last-" .. run, "w")
	if f then
		f:write(os.date("%Y-%m-%d %H:%M ") .. result .. "\n")
		f:close()
	end
	log(run .. ": " .. result)
end

local function isScreenLocked()
	local props = hs.caffeinate.sessionProperties() or {}
	return props["CGSSessionScreenIsLocked"] == true
end

local function bundleID(app)
	local info = hs.application.infoForBundlePath(app.path)
	return info and info.CFBundleIdentifier
end

local function warn(text)
	log("WARN " .. text)
	hs.alert.show("Workday apps: " .. text, 10)
end

-- Names of the apps whose path is gone or has no bundle ID, after warning about each.
local function missingApps(apps)
	local missing = {}
	for _, app in ipairs(apps) do
		if not bundleID(app) then
			warn(app.name .. " not found at " .. app.path)
			table.insert(missing, app.name)
		end
	end
	return missing
end

local function withMissing(result, missing)
	return #missing > 0 and (result .. "; missing " .. table.concat(missing, ", ")) or result
end

local function runningCloseApps()
	local apps = {}
	for _, closeApp in ipairs(CLOSE_APPS) do
		local id = bundleID(closeApp)
		if id then
			-- applicationsForBundleID came back empty right after the dialog closed while both
			-- apps were running, and a second lookup found them, so fall back to get().
			local found = hs.application.applicationsForBundleID(id) or {}
			if #found == 0 then
				found = { hs.application.get(id) }
			end
			for _, app in ipairs(found) do
				table.insert(apps, app)
			end
		end
	end
	return apps
end

-- Run /usr/bin/open on each app and call done(started, failed) once all have answered.
local function launch(apps, args, done)
	local started, failed, pending = {}, {}, #apps
	local function finish(ok, name)
		table.insert(ok and started or failed, name)
		pending = pending - 1
		if pending == 0 then
			done(started, failed)
		end
	end
	for _, app in ipairs(apps) do
		if not bundleID(app) then
			warn(app.name .. " not found at " .. app.path)
			finish(false, app.name)
		else
			local taskArgs = {}
			for _, a in ipairs(args) do
				table.insert(taskArgs, a)
			end
			table.insert(taskArgs, app.path)
			local task = hs.task.new("/usr/bin/open", function(exitCode, _, stdErr)
				if exitCode ~= 0 then
					warn("could not open " .. app.name .. ": " .. (stdErr or ""):gsub("%s+$", ""))
				end
				finish(exitCode == 0, app.name)
			end, taskArgs)
			table.insert(M.tasks, task) -- keep a reference until it answers
			task:start()
		end
	end
end

local function openResult(started, failed)
	local parts = {}
	if #started > 0 then
		table.insert(parts, "started " .. table.concat(started, ", "))
	end
	if #failed > 0 then
		table.insert(parts, "failed " .. table.concat(failed, ", "))
	end
	return table.concat(parts, "; ")
end

-- how: nil for an on-time run, "catch-up" or "manual".
local function openApps(how)
	M.tasks = {}
	if how ~= "manual" then
		-- Marks the run done now, so a check while open is still answering cannot start a second one.
		os.execute('/bin/mkdir -p "' .. STATE_DIR .. '"')
		local f = io.open(STATE_DIR .. "/last-open", "w")
		if f then
			f:write(os.date("%Y-%m-%d %H:%M ") .. "starting\n")
			f:close()
		end
	end
	-- -g asks for the background; Slack and Teams still come forward.
	launch(OPEN_APPS, { "-g" }, function(started, failed)
		if os.date("%w") ~= "5" then
			return M.reportOpen(how, openResult(started, failed))
		end
		-- Roar opens last, so it ends up in front.
		M.fridayTimer = hs.timer.doAfter(5, function()
			launch({ ROAR }, {}, function(rStarted, rFailed)
				for _, n in ipairs(rStarted) do
					table.insert(started, n)
				end
				for _, n in ipairs(rFailed) do
					table.insert(failed, n)
				end
				M.reportOpen(how, openResult(started, failed))
			end)
		end)
	end)
end

function M.reportOpen(how, result)
	if how == "manual" then
		log("open (manual): " .. result)
		announce("manual open: " .. result)
		return
	end
	markDone("open", result .. (how and (" (" .. how .. ")") or ""))
	if how == "catch-up" then
		announce("catch-up: " .. result)
	end
end

local function quitApps(reason, attempt)
	attempt = attempt or 1
	local apps = runningCloseApps()
	if #apps == 0 and attempt < 3 then
		M.quitRetryTimer = hs.timer.doAfter(2, function()
			quitApps(reason, attempt + 1)
		end)
		return
	end
	local quit = {}
	for _, app in ipairs(apps) do
		table.insert(quit, app:name())
		app:kill() -- graceful quit, so Teams can still ask about a call
	end
	local result =
		withMissing(#quit > 0 and ("quit " .. table.concat(quit, ", ")) or "nothing running", missingApps(CLOSE_APPS))
	if reason == "manual" then
		log("close (manual): " .. result)
		announce("manual close: " .. result)
		return
	end
	markDone("close", result .. (reason and (" (" .. reason .. ")") or ""))
end

local function askToClose()
	closing = true
	local snooze = "Snooze " .. SNOOZE_MINUTES .. " min"
	local script = string.format(
		'display dialog "Quitting Slack and Teams." with title "Workday apps" '
			.. 'buttons {"Skip today", "%s", "Quit now"} default button "Quit now" giving up after %d',
		snooze,
		DIALOG_SECONDS
	)
	M.dialogTask = hs.task.new("/usr/bin/osascript", function(exitCode, stdOut, stdErr)
		local out = stdOut or ""
		if exitCode ~= 0 then
			log("close: dialog failed (" .. (stdErr or ""):gsub("%s+$", "") .. "), quitting anyway")
			closing = false
			quitApps("no dialog")
		elseif out:find("gave up:true", 1, true) then
			closing = false
			quitApps("no answer")
		elseif out:find("Skip today", 1, true) then
			closing = false
			markDone("close", "skipped today")
		elseif out:find(snooze, 1, true) then
			log("close: snoozed " .. SNOOZE_MINUTES .. " min")
			M.snoozeTimer = hs.timer.doAfter(SNOOZE_MINUTES * 60, function()
				closing = false
				M.check()
			end)
		else
			closing = false
			quitApps(nil)
		end
	end, { "-e", script })
	M.dialogTask:start()
end

function M.check()
	local wday = tonumber(os.date("%w"))
	if wday == 0 or wday == 6 then
		return
	end
	local date = today()
	if isPaused(date) then
		if not loggedPause[date] then
			loggedPause[date] = true
			log("paused date, no runs")
		end
		return
	end

	local now = nowMinutes()
	local openAt, closeAt = minutesOf(OPEN_AT), minutesOf(CLOSE_AT)

	if now >= openAt and now < closeAt and not doneToday("open") then
		openApps(now - openAt > LATE_MINUTES and "catch-up" or nil)
	end

	if now >= closeAt and now <= minutesOf(CLOSE_UNTIL) and not doneToday("close") and not closing then
		if #runningCloseApps() == 0 then
			if not emptySince or emptySince.date ~= date then
				emptySince = { date = date, time = os.time() }
			elseif os.time() - emptySince.time >= EMPTY_SECONDS then
				emptySince = nil
				markDone("close", withMissing("nothing running", missingApps(CLOSE_APPS)))
			end
			return
		end
		emptySince = nil
		if isScreenLocked() then
			quitApps("screen locked") -- nobody is there to answer the dialog
		else
			askToClose()
		end
	end
end

-- run: "open" or "close". Called by the hyper+O and hyper+C hotkeys in init.lua.
function M.manual(run)
	if run == "open" then
		openApps("manual")
	else
		quitApps("manual")
	end
end

function M.start()
	missingApps({ SLACK, TEAMS, ROAR }) -- warn at load, not only at 07:00
	M.timer = hs.timer.doEvery(60, M.check)
	M.watcher = hs.caffeinate.watcher.new(function(event)
		if event == hs.caffeinate.watcher.systemDidWake or event == hs.caffeinate.watcher.screensDidUnlock then
			M.check()
		end
	end)
	M.watcher:start()
	M.startTimer = hs.timer.doAfter(5, M.check)
	return M
end

return M
