# AppleScript Apps

This directory contains AppleScript source files that are automatically built
into macOS applications during installation.

## Quick Start

### 1. Create an AppleScript

Create a new `.applescript` file in this directory:

```applescript
-- my-app.applescript
on run
    display notification "Hello from My App!" with title "My App"
end run
```

### 2. Add a Custom Icon (Optional)

Convert an image to `.icns` format:

```bash
./create-icon.sh ~/Downloads/icon.png my-app
```

This creates `icons/my-app.icns` which will be automatically applied.

### 3. Build and Install

```bash
cd ~/zdotdir
./install.sh --component apps
```

The app will be installed to `~/Applications/My App.app` and appear in
Spotlight/Alfred.

## File Naming Convention

- **Script**: Use lowercase with hyphens: `my-app.applescript`
- **Icon**: Match the script name: `icons/my-app.icns`
- **Resulting App**: Title case with spaces: `My App.app`

**Examples:**

| Script File                 | Icon File                  | App Name            |
| --------------------------- | -------------------------- | ------------------- |
| `relink.applescript`        | `icons/relink.icns`        | `Relink.app`        |
| `toggle-wifi.applescript`   | `icons/toggle-wifi.icns`   | `Toggle Wifi.app`   |
| `open-settings.applescript` | `icons/open-settings.icns` | `Open Settings.app` |

## AppleScript Tips

### Running Shell Commands

```applescript
on run
    -- Simple command
    do shell script "echo 'Hello from shell'"

    -- With error handling
    try
        do shell script "killall DisplayLinkUserAgent"
    on error errMsg
        display notification errMsg with title "Error"
    end try
end run
```

### Showing Notifications

```applescript
-- Basic notification
display notification "Message" with title "Title"

-- With sound
display notification "Done!" with title "Success" sound name "Glass"

-- With subtitle
display notification "Details here" with title "Main Title" subtitle "Subtitle"
```

### Delays

```applescript
-- Wait 2 seconds
delay 2
```

### User Dialogs

```applescript
-- Simple dialog
display dialog "Are you sure?" buttons {"Cancel", "OK"} default button "OK"

-- Get user input
set userInput to text returned of (display dialog "Enter something:" default answer "")
```

### File Operations

```applescript
-- Open an application
do shell script "open -a 'System Settings'"

-- Open a URL
open location "https://example.com"
```

## Installation & Uninstallation

### Install/Update Apps

```bash
# Install all apps
./install.sh --component apps

# Install/update everything
./install.sh --component all
```

### Uninstall Apps

```bash
# Remove apps only
./uninstall.sh --component apps

# Remove everything
./uninstall.sh --component all
```

The uninstall script safely removes only apps that have matching source files in
this directory.

## Integration

Once installed, your apps can be:

- Launched from **Spotlight** (Cmd+Space)
- Launched from **Alfred** or other launchers
- Added to the **Dock**
- Assigned **keyboard shortcuts** via System Settings
- Bound to **AeroSpace keybindings**
- Triggered by automation tools like **Hammerspoon** or **BetterTouchTool**

## Examples

### Example 1: Relink DisplayLink Displays

```applescript
-- relink.applescript
on run
    display notification "Reconnecting DisplayLink displays..." with title "Relink DisplayLink"

    try
        do shell script "killall DisplayLinkUserAgent 2>/dev/null"
    end try

    try
        do shell script "killall DisplayLinkXpcService 2>/dev/null"
    end try

    delay 2

    do shell script "open -a 'DisplayLink Manager'"

    display notification "DisplayLink Manager restarted. Displays should reconnect soon." with title "Relink DisplayLink" sound name "Glass"
end run
```

### Example 2: Toggle Dark Mode

```applescript
-- toggle-dark-mode.applescript
on run
    tell application "System Events"
        tell appearance preferences
            set dark mode to not dark mode
        end tell
    end tell

    display notification "Dark mode toggled" with title "Display Settings"
end run
```

### Example 3: Open Specific Folder

```applescript
-- open-work.applescript
on run
    do shell script "open ~/Projects/work"
    display notification "Opened work folder" with title "Workspace"
end run
```

## Troubleshooting

### App doesn't appear in Spotlight

- Wait a few seconds for Spotlight to index
- Try rebuilding: `./install.sh --component apps`
- Force Spotlight reindex: `mdutil -E /Applications`

### Icon doesn't show

- Make sure icon file matches script name exactly
- Rebuild the app: `./install.sh --component apps`
- Restart Finder: `killall Finder`

### Permission errors

Some operations may require additional permissions:

- Go to **System Settings → Privacy & Security**
- Grant permissions for Accessibility, Automation, etc.

## Resources

- [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
- [Shell Scripting from AppleScript](https://developer.apple.com/library/archive/technotes/tn2065/)
- [SF Symbols](https://developer.apple.com/sf-symbols/) - macOS icons
- [macOS Icons](https://macosicons.com/) - Community icon gallery
