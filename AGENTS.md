# Repository Guidelines

## Project Structure & Module Organization

The theme source is under `theme/`: `theme.css` plus its manifest, version map, bundled fonts, and license texts. The optional desktop companion plugin is under `companion_plugin/`: edit TypeScript in `companion_plugin/src/`, plugin CSS in `companion_plugin/styles.css`, and treat `companion_plugin/main.js` as generated build output. Automation is in `tools/`; `tools/gallery/` holds the gallery fixture and generator, while reviewed visual baselines are in `screenshots/`. Packaging writes release artifacts to the ignored `artifacts/` directory.

## Build, Check, and Development Commands

Use Node.js 24 (`.nvmrc`), npm, and PowerShell 7. Install the locked dependency graph with `npm ci`.

- `npm run check` validates metadata, lints both CSS files and companion code, and type-checks TypeScript.
- `npm run build` builds the companion bundle and produces the distributable theme CSS.
- `npm run dev --workspace claude-theme-companion` watches and rebuilds the companion plugin.
- `npm run package` creates release archives and SHA-256 checksums.
- `pwsh -NoProfile -File tools/gallery/generate-gallery.ps1 -VaultName "My Vault"` refreshes screenshots; Obsidian must be open and its CLI available.

## Coding Style & Naming Conventions

Follow `.editorconfig`: UTF-8, LF endings, final newline, spaces, and two-space indentation. Keep TypeScript strict, use `PascalCase` for classes and interfaces, `camelCase` for members and functions, and descriptive uppercase names for constants. CSS custom properties use the existing `--claude-*` naming scheme. Run Stylelint and the Obsidian ESLint configuration through `npm run check`; do not hand-edit generated `companion_plugin/main.js`.

## Testing & Visual Validation

There is no standalone unit-test suite. The required quality gate is `npm run check`, `npm run build`, and `npm run package`. For visual changes, regenerate the gallery and inspect every light and dark image at full resolution. Check reduced-motion behavior and ensure `git diff --exit-code -- companion_plugin/main.js` would pass after building.

## Commit & Pull Request Guidelines

History uses short Conventional Commit-style subjects such as `feat: add warm light palette` and `fix: misc fixes`. Keep each commit focused. Pull requests must summarize the visual or behavioral change and record validation performed. Link relevant issues, include refreshed screenshots for visual work, and note reduced-motion impact. Keep theme and companion version changes independent and update all corresponding package, manifest, and versions files together.
