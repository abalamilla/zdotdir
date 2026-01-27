-- Relink DisplayLink Displays
-- Fix DisplayLink displays when they don't reconnect properly after wake

on run
	-- Show initial notification
	display notification "Reconnecting DisplayLink displays..." with title "Relink DisplayLink"

	-- Kill DisplayLink processes
	try
		do shell script "killall DisplayLinkUserAgent 2>/dev/null"
	end try

	try
		do shell script "killall DisplayLinkXpcService 2>/dev/null"
	end try

	delay 2

	-- Restart DisplayLink Manager
	try
		do shell script "open -a 'DisplayLink Manager'"

		-- Show success notification
		display notification "DisplayLink Manager restarted. Displays should reconnect in a few seconds..." with title "Relink DisplayLink" sound name "Glass"

	on error errMsg
		-- Show error notification
		display notification "Failed to restart DisplayLink Manager: " & errMsg with title "Relink DisplayLink"
	end try

end run