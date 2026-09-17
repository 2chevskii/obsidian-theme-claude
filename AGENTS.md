# Repository Guidelines

## Project Structure & Module Organization

`src/theme.scss` is the theme source; `manifest.json` and `versions.json` contain
Obsidian release metadata. `assets/fonts/` holds local WOFF2 files and licenses that
are embedded into the distributable CSS. Automation is in `tools/`, with the
gallery fixture and generator under `tools/gallery/`. Generated screenshots are
in `assets/screenshots/`.

## Build, Check, and Development Commands

Use Node.js 24, npm, and PowerShell 7.

- `npm ci` installs the locked dependencies.
- `npm run check` lints the SCSS source and builds the release files.
- `npm run lint` lints the SCSS source.
- `npm run build` creates release-ready `dist/theme.css` and `dist/manifest.json` files.
- `npm run gallery` captures screenshots with real Obsidian in a locked `linux/amd64` Docker runtime.
- `npm run gallery:verify` validates the scenario manifest, PNG dimensions, and Markdown links.

## Style, Validation, and Releases

Follow `.editorconfig`: UTF-8, LF, final newline, spaces, and two-space
indentation. Keep CSS custom properties in the established `--claude-*`
namespace. Run checks, gallery capture, and gallery verification before submitting
visual changes; inspect refreshed screenshots and reduced-motion behavior.

Keep `package.json` and `manifest.json` versions identical, and add the same
version to `versions.json`. Pushing the matching numeric tag runs
`release.yml`, which validates and builds the theme before creating a draft release with
`manifest.json` and `theme.css`. Review its notes and publish
the draft manually.

## Commits and Pull Requests

Use focused Conventional Commit-style subjects such as `feat: add warm palette`
or `fix: correct metadata`. Describe behavior changes and validation in pull
requests. Include updated screenshots for visual changes.
