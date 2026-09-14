# Claude for Obsidian

An unofficial Obsidian theme inspired by the current Claude web interface. It
ships with coordinated light and dark palettes, Anthropic typography, compact
recessed sidebars, floating tabs, refined modal surfaces, and an optional
desktop companion plugin for behavior CSS cannot provide.

This project is not affiliated with or endorsed by Anthropic or Obsidian.

| Light | Dark |
| --- | --- |
| ![Claude theme in light mode](screenshots/overview-light.png) | ![Claude theme in dark mode](screenshots/overview-dark.png) |

[Open the full screenshot gallery](screenshots/README.md).

## Highlights

- Claude-inspired light and dark color systems.
- Bundled Anthropic Sans, Serif, and Mono variable fonts.
- Independent interface, note, and heading font selectors through Style Settings.
- Floating editor tabs, recessed sidebars, compact explorer actions, centered status bar, and polished window controls.
- Claude-like inline code, code blocks, tables, metadata, callouts, and reading surfaces.
- Optional auto-hiding status bar and Obsidian Sync indicator toggle.
- Modal backdrop blur and separated prompt input/results surfaces.
- Companion-powered closing animations, search-result transitions, live-preview heading-marker animation, and click-through status-bar activation zone.
- Reduced-motion support.

## Installation

### Theme

1. Download `claude-theme-<version>.zip` from the matching numeric GitHub Release.
2. Extract the `Claude` folder into `<vault>/.obsidian/themes/`.
3. In Obsidian, open **Settings → Appearance → Themes** and select **Claude**.

The numeric release tag always matches the version in the root `manifest.json`,
which keeps the theme compatible with Obsidian's release updater.

### Claude Theme Companion

1. Download `claude-theme-companion-<version>.zip` from the corresponding
   `companion-<version>` GitHub Release.
2. Extract `claude-theme-companion` into `<vault>/.obsidian/plugins/`.
3. Reload Obsidian, then enable **Claude Theme Companion** under Community plugins.

The companion is desktop-only and intentionally useful only with the Claude
theme. The theme remains fully usable without it.

### Style Settings

Install and enable the community plugin
[Style Settings](https://github.com/mgmeyers/obsidian-style-settings), then open
**Settings → Style Settings → Claude**. You can select Anthropic Sans, Serif, or
Mono independently for the interface, note body, and headings; auto-hide the
status bar; and hide the Obsidian Sync status item.

## Development

Requirements:

- Node.js 24 (see `.nvmrc`)
- npm
- PowerShell 7 for packaging and gallery generation
- Obsidian 1.10.6 or newer

```powershell
fnm use
npm ci
npm run check
npm run build
npm run package
```

Release-ready archives, flat Obsidian assets, and SHA-256 checksums are written
to `artifacts/`. The distributable theme CSS embeds the local WOFF2 files, so a
GitHub Release remains self-contained even though Obsidian downloads only
`manifest.json` and `theme.css` for a theme update.

### Screenshot gallery

The gallery generator temporarily installs the repository build into a selected
open vault, creates a disposable showcase note, captures the main states, and
restores the previous theme, plugin files, active note, and color mode.

```powershell
npm run build
pwsh -NoProfile -File scripts/generate-gallery.ps1 -VaultName "My Vault"
```

Obsidian must be open, the official Obsidian CLI must be available, and Style
Settings should be installed for the settings screenshot. Use `-KeepFixture` to
leave the generated showcase note in the vault.

## Repository layout

- `theme.css`, `manifest.json`, `versions.json` — theme source and release metadata.
- `fonts/` — local WOFF2 font resources used during development and embedded at build time.
- `companion/` — companion plugin source, manifest, styles, and build output.
- `gallery/showcase.md` — deterministic screenshot fixture.
- `scripts/` — metadata checks, theme build, packaging, and gallery automation.
- `screenshots/` — generated gallery and community-directory thumbnail.

## Releases

- Push a numeric tag matching `manifest.json`, for example `1.0.58`, to publish the theme.
- Push `companion-<version>`, for example `companion-1.0.0`, to publish the plugin.
- Each release is rebuilt, validated, packaged, checksummed, and provenance-attested in GitHub Actions.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the release checklist and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for font and trademark notices.

## License

Theme and plugin code are available under the MIT License. The files in `fonts/`
are excluded from that license and remain the property of their respective
owner; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
