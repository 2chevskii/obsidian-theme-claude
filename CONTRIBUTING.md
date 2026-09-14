# Contributing

## Local checks

Use Node.js 24 and install the exact dependency graph from `package-lock.json`.

```powershell
fnm use
npm ci
npm run check
npm run build
npm run package
```

Run the gallery generator after visual changes and inspect every generated
image at full resolution. Do not commit visual changes with stale screenshots.

## Versioning

For each release, update `package.json` and `manifest.json` to the same
Semantic Versioning value, then add the corresponding minimum Obsidian version
to `versions.json`. `npm run check:metadata` rejects version drift.

## Release checklist

1. Run checks, build, and packaging locally.
2. Generate and inspect the screenshot gallery.
3. Push a numeric tag matching `manifest.json`.
4. Verify that GitHub Actions created a draft release with `manifest.json` and
   `theme.css`.
5. Add release notes, publish the draft, and verify the release assets.
