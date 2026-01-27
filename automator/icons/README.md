# AppleScript App Icons

This directory contains `.icns` icon files for AppleScript apps.

## Usage

### Creating Icons

Use the `create-icon.sh` script to convert any image to `.icns` format:

```bash
cd ~/zdotdir/automator
./create-icon.sh <image-file> <app-name>
```

**Example:**

```bash
./create-icon.sh ~/Downloads/display-icon.png relink
```

This will create `icons/relink.icns` which will be automatically applied to
`Relink.app` when you run:

```bash
cd ~/zdotdir
./install.sh --component apps
```

## Requirements

- Source image should be at least **1024x1024 pixels** for best quality
- Supported formats: PNG, JPG, TIFF, etc. (anything `sips` can read)
- Icon filename must match the AppleScript filename (without `.applescript`
  extension)

## Icon Naming

Icons must match the script name in lowercase with hyphens:

| Script File               | Icon File                |
| ------------------------- | ------------------------ |
| `relink.applescript`      | `icons/relink.icns`      |
| `my-app.applescript`      | `icons/my-app.icns`      |
| `toggle-wifi.applescript` | `icons/toggle-wifi.icns` |

## Manual Creation

If you prefer to create `.icns` files manually:

1. Use online converters like
   [CloudConvert](https://cloudconvert.com/png-to-icns)
2. Use macOS apps like Image2icon or Icon Slate
3. Use the built-in `iconutil` command (see `create-icon.sh` for reference)

## Finding Icons

- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon library
- [macOS Icon Gallery](https://macosicons.com/) - Community icons
- [Flaticon](https://www.flaticon.com/) - Free icons (check license)
- Create your own in design tools like Figma, Sketch, or Affinity Designer
