# Repository Guidelines

## Project Structure & Module Organization

`theme.css` is the theme source; `manifest.json` and `versions.json` contain
Obsidian release metadata. `assets/fonts/` holds local WOFF2 files and licenses that
are embedded into the distributable CSS. Automation is in `tools/`, with the
gallery fixture and generator under `tools/gallery/`. Generated screenshots are
in `assets/screenshots/`; package outputs are ignored in `artifacts/`.

## Build, Check, and Development Commands

Use Node.js 24 (`.nvmrc`), npm, and PowerShell 7.

- `npm ci` installs the locked dependencies.
- `npm run check` validates metadata and lints `theme.css`.
- `npm run build` creates the release-ready `dist/theme.css` and `dist/manifest.json` files for Claude.md.
- `npm run package` creates the theme ZIP and SHA-256 checksum.
- `npm run clean` removes `dist/` and `artifacts/`.
- `pwsh -NoProfile -File tools/gallery/generate-gallery.ps1 -VaultName "My Vault"` refreshes screenshots.

## Style, Validation, and Releases

Follow `.editorconfig`: UTF-8, LF, final newline, spaces, and two-space
indentation. Keep CSS custom properties in the established `--claude-*`
namespace. Run checks, build, and package before submitting visual changes;
inspect refreshed screenshots and reduced-motion behavior.

Keep `package.json` and `manifest.json` versions identical, and add the same
version to `versions.json`. Pushing the matching numeric tag runs
`start_release.yml`, which validates and builds the theme before creating a
draft release with `manifest.json` and `theme.css`. Review its notes and publish
the draft manually.

## Commits and Pull Requests

Use focused Conventional Commit-style subjects such as `feat: add warm palette`
or `fix: correct metadata`. Describe behavior changes and validation in pull
requests. Include updated screenshots for visual changes.
