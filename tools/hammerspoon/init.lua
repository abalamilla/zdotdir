-- BEGIN

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
MyWatcher = hs.pathwatcher.new(configFile, ReloadConfig):start()
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

function ToggleMute()
	local teams = hs.application.find("com.microsoft.teams2")
	if not (teams == nil) then
		hs.eventtap.keyStroke({ "cmd", "shift" }, "m", 0, teams)
	end
end

function TypePasteboardContet()
	hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end

local hyper = { "cmd", "alt", "ctrl", "shift" }

hs.hotkey.bind(hyper, "1", ToggleMute)
hs.hotkey.bind(hyper, "v", TypePasteboardContet)

hs.loadSpoon("SpoonInstall")

-- ctrl + alt + hotkey
spoon.SpoonInstall:andUse("AppLauncher", {
	hotkeys = {
		c = "Calendar",
		i = "iTerm",
		t = "Microsoft Teams",
		o = "Microsoft Outlook",
	},
})

function AppID(app)
	return hs.application.infoForBundlePath(app)["CFBundleIdentifier"]
end

local chromeBrowser = AppID("/Applications/Google Chrome.app")
-- safariBrowser = appID("/Applications/Safari.app")

DefaultBrowser = chromeBrowser

spoon.SpoonInstall:andUse("URLDispatcher", {
	config = {
		url_patterns = {
			{ "msteams:", "com.microsoft.teams2" },
		},
		url_redir_decoders = {
			{ "MS Teams URLs", "(https://teams.microsoft.com.*)", "msteams:%1", true },
		},
		default_handler = DefaultBrowser,
	},
	start = true,
})

-- keychain search, copy and paste
function KeychainItemToPasteboard()
	local currentApp = hs.application.frontmostApplication()

	hs.focus()
	local button, text = hs.dialog.textPrompt("key", "text", "", "Ok", "Cancel", true)

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

local batteryWatcher = hs.battery.watcher.new(BatteryCallback):start()

spoon.SpoonInstall:andUse("WindowHalfsAndThirds", {
	config = {
		use_frame_correctness = true,
	},
	hotkeys = {
		left_half = { { "ctrl", "cmd" }, "Left" },
		right_half = { { "ctrl", "cmd" }, "Right" },
		max_toggle = { hyper, "Up" },
		undo = { hyper, "z" },
		center = { hyper, "c" },
		larger = { hyper, "Right" },
		smaller = { hyper, "Left" },
	},
})

spoon.SpoonInstall:andUse("WindowScreenLeftAndRight", {
	hotkeys = {
		screen_left = { hyper, "2" },
		screen_right = { hyper, "3" },
	},
})

spoon.SpoonInstall:andUse("KSheet", {
	hotkeys = {
		toggle = { hyper, "0" },
	},
})

local targets = {}
local currentSpaceWindows = hs.window.filter.new()
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local binding = hs.hotkey.modal.new({ "alt" }, "tab")
local spaceWatcher
local textStyle = {
	font = {
		name = hs.styledtext.defaultFonts.boldSystem,
		size = 72,
	},
	color = { white = 1, alpha = 1 },
}

currentSpaceWindows:setCurrentSpace(true)
spaceWatcher = hs.spaces.watcher.new(function()
	binding:exit()
	spaceWatcher:stop()
end)

-- Making a selection
for i in alphabet:gmatch(".") do
	local letter = i
	binding:bind({}, letter, nil, function()
		local target = targets[letter]
		if target ~= nil then
			target.window:focus()
			target.window:focus()
			local frame = target.window:frame()
			hs.mouse.setAbsolutePosition(hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2))
			target.box:setFillColor({ white = 0.125, alpha = 0.8 })
			target.box:hide(0.3)
			hs.timer.doAfter(0.3, function()
				target.box:delete()
			end)
			target.text:hide(0.3)
			hs.timer.doAfter(0.3, function()
				target.text:delete()
			end)
			target.app:hide(0.3)
			hs.timer.doAfter(0.3, function()
				target.app:delete()
			end)
			targets[letter] = nil
			binding:exit()
		end
	end)
end

-- Alternative exit points
binding:bind({}, "escape", nil, function()
	binding:exit()
end)
binding:bind({ "alt" }, "tab", nil, function()
	binding:exit()
end)

-- Binding enter
binding.entered = function()
	targets = {}
	spaceWatcher:start()

	-- Get list of windows
	local filteredWindows = {}
	local windows = currentSpaceWindows:getWindows()
	for _, window in ipairs(windows) do
		if window:isStandard() and window:isVisible() or window:id() == window:application():mainWindow():id() then
			filteredWindows[#filteredWindows + 1] = window
		end
	end
	table.sort(filteredWindows, function(a, b)
		local af = a:frame()
		local bf = b:frame()

		if af.x ~= bf.x then
			return af.x < bf.x
		end
		if af.y ~= bf.y then
			return af.y < bf.y
		end
		return nil
	end)

	-- Parse, render, and bind shortcuts
	for _, window in ipairs(filteredWindows) do
		local t = { window = window }

		-- Convert window's application initial to a shortcut
		local appName = window:application():title():sub(1, 1):upper()
		if not alphabet:find(appName) then
			appName = "A"
		end
		local tries = 0
		while targets[appName] ~= nil do
			local i = (alphabet:find(appName) % #alphabet) + 1
			appName = alphabet:sub(i, i)
			tries = tries + 1
			if tries == 26 then
				return
			end -- we've run out of shortcuts
		end

		-- Render shortcut
		local styledText = hs.styledtext.new(appName, textStyle)
		local textDims = hs.drawing.getTextDrawingSize(styledText)
		local frame = window:frame()
		local textRect = hs.geometry.rect(
			frame.x + frame.w / 2 - textDims.w / 2 - 2,
			frame.y + frame.h / 2 - textDims.h / 2 - 16,
			textDims.w + 8,
			textDims.h
		)
		local boxRect = hs.geometry.rect(
			frame.x + frame.w / 2 - textDims.w / 2 - 26,
			frame.y + frame.h / 2 - textDims.h / 2 - 24,
			textDims.w + 52,
			textDims.h + 48
		)
		local appRect = hs.geometry.rect(frame.x + frame.w / 2 - 16, frame.y + frame.h / 2 + 20, 32, 32)
		t.box = hs.drawing.rectangle(boxRect)
		t.box:setLevel("overlay")
		t.box:setFillColor({ white = 0.125, alpha = 0.7 })
		t.box:setFill(true)
		t.box:setStroke(false)
		t.box:setRoundedRectRadii(8, 8)
		t.text = hs.drawing.text(textRect, styledText)
		t.text:setLevel("overlay")
		t.app = hs.drawing.appImage(appRect, window:application():bundleID())
		t.box:show()
		t.text:show()
		t.app:show()

		-- Add to targets
		targets[appName] = t
	end
end

-- Binding exit
binding.exited = function()
	for k in pairs(targets) do
		targets[k].box:delete()
		targets[k].text:delete()
		targets[k].app:delete()
	end
	targets = {}
end
-- END
