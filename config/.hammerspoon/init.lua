-- BEGIN
local hyper = { "cmd", "alt", "ctrl", "shift" }

-- automatic hammerspoon config reload
function ReloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

local configFile = os.getenv("HOME") .. "/.hammerspoon/"
hs.pathwatcher.new(configFile, ReloadConfig):start()
hs.hotkey.bind(hyper, "r", function()
	ReloadConfig(configFile)
	hs.alert.show("Config reloaded!")
end)
hs.alert.show("Config loaded!")

function ApplicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		if appName == "Finder" then
			-- Bring all Finder windows forward when one gets activated
			appObject:selectMenuItem({ "Window", "Bring All to Front" })
		end
	end
end

local appWatcher = hs.application.watcher.new(ApplicationWatcher)
appWatcher:start()

-- nil when the app is gone, instead of an error
function AppID(app)
	local info = hs.application.infoForBundlePath(app)
	return info and info["CFBundleIdentifier"]
end

-- Read from the app, because Teams changed its bundle ID once (com.microsoft.teams to teams2).
TeamsID = AppID("/Applications/Microsoft Teams.app")
if not TeamsID then
	hs.alert.show("Microsoft Teams not found: hyper+1 and Teams links are off", 10)
end

function ToggleMute()
	local teams = TeamsID and hs.application.find(TeamsID)
	if not (teams == nil) then
		hs.eventtap.keyStroke({ "cmd", "shift" }, "m", 0, teams)
	end
end

function TypePasteboardContet()
	hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end

hs.hotkey.bind(hyper, "1", ToggleMute)
hs.hotkey.bind(hyper, "v", TypePasteboardContet)

hs.loadSpoon("SpoonInstall")

function FindBrowser()
	local browsers = { "Brave Browser", "Google Chrome", "Safari", "Firefox" }
	local locations = { "/Applications", os.getenv("HOME") .. "/Applications" }

	for _, browserName in ipairs(browsers) do
		for _, location in ipairs(locations) do
			local browserPath = location .. "/" .. browserName .. ".app"
			if hs.fs.attributes(browserPath) then
				return AppID(browserPath)
			end
		end
	end

	return nil
end

DefaultBrowser = FindBrowser()

-- Without Teams, leave Teams links to the browser instead of rewriting them to msteams:.
spoon.SpoonInstall:andUse("URLDispatcher", {
	config = {
		url_patterns = TeamsID and {
			{ "msteams:", TeamsID },
		} or {},
		url_redir_decoders = TeamsID and {
			{ "MS Teams URLs", "(https://teams.microsoft.com.*)", "msteams:%1", true },
		} or {},
		default_handler = DefaultBrowser,
	},
	start = true,
})

-- keychain search, copy and paste
function KeychainItemToPasteboard()
	local currentApp = hs.application.frontmostApplication()

	hs.focus()
	local _, text = hs.dialog.textPrompt("key", "text", "", "Ok", "Cancel", true)

	-- logname = os.getenv("LOGNAME")
	local command = "security find-generic-password -w -a " .. text .. " | /usr/local/bin/pbcopy-plus"

	os.execute(command)

	currentApp:activate()
end

hs.hotkey.bind(hyper, "k", KeychainItemToPasteboard)

-- battery notification
function BatteryCallback()
	if hs.battery.isCharged() then
		hs.notify
			.new(nil, {
				informativeText = "🔌 Please unplug the charger!",
				soundName = "Sosumi",
				subTitle = "🔋 I'm fully charged",
				title = "Battery charged",
			})
			:send()
	end

	if hs.battery.percentage() < 25 and not hs.battery.isCharging() then
		hs.notify
			.new(nil, {
				informativeText = "🔌 Please plug me the charger!",
				soundName = "Sosumi",
				subTitle = "🪫 I'm running out of energy",
				title = "Low battery",
			})
			:send()
	end
end

hs.battery.watcher.new(BatteryCallback):start()

spoon.SpoonInstall:andUse("KSheet", {
	hotkeys = {
		toggle = { hyper, "0" },
	},
})

-- open and quit Slack, Teams and Roar around working hours (workday_apps.lua)
WorkdayApps = require("workday_apps").start()
hs.hotkey.bind(hyper, "o", function()
	WorkdayApps.manual("open")
end)
hs.hotkey.bind(hyper, "c", function()
	WorkdayApps.manual("close")
end)

-- END
