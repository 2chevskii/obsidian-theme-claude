# Claude for Obsidian

An unofficial Obsidian theme inspired by the current Claude web interface. It
includes Default and Warm light palettes, a coordinated dark palette, bundled
open-source typography, floating tabs, recessed sidebars, and refined editor,
modal, table, and metadata surfaces.

This project is not affiliated with or endorsed by Anthropic or Obsidian.

| Light | Dark |
| --- | --- |
| ![Claude theme in light mode](screenshots/overview-light.png) | ![Claude theme in dark mode](screenshots/overview-dark.png) |

[Open the full screenshot gallery](screenshots/README.md).

## Installation

1. Download `manifest.json` and `theme.css` from the GitHub Release matching
   the theme version.
2. Place them in `<vault>/.obsidian/themes/Claude/`.
3. In Obsidian, open **Settings → Appearance → Themes** and select **Claude**.

Install and enable the [Style Settings](https://github.com/mgmeyers/obsidian-style-settings)
community plugin to switch between Default and Warm light palettes, auto-hide
the status bar, or hide the Obsidian Sync status item.

## Development

Requirements: Node.js 24 (`.nvmrc`), npm, PowerShell 7, and Obsidian 1.10.6 or
newer.

```powershell
fnm use
npm ci
npm run check
npm run build
npm run package
```

`npm run package` writes a ZIP archive and checksums to `artifacts/`; `npm run
clean` removes `dist/` and `artifacts/`. The distributable CSS embeds bundled
WOFF2 files so the release is self-contained.

### Screenshot gallery

After visual changes, generate and inspect the gallery at full resolution.

```powershell
npm run build
pwsh -NoProfile -File tools/gallery/generate-gallery.ps1 -VaultName "My Vault"
```

Obsidian must be open, its official CLI must be available, and Style Settings
should be installed for the settings screenshot.

## Repository layout

- `theme.css`, `manifest.json`, `versions.json` — theme source and release metadata.
- `fonts/` — local WOFF2 resources embedded at build time.
- `tools/` — validation, build, package, font, and gallery automation.
- `screenshots/` — generated gallery and community-directory thumbnail.

## Releases

Update `package.json`, `manifest.json`, and `versions.json`, then push a
numeric tag matching `manifest.json`, for example `1.0.0`. GitHub Actions runs
checks, builds the release assets, and creates a draft release. Add release
notes and publish the draft; Obsidian then downloads `manifest.json` and
`theme.css` from that release for theme updates.

## License

Theme code is available under the MIT License. Files in `fonts/` are
distributed under the SIL Open Font License 1.1; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
