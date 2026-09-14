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

Run the gallery generator after any visual change and inspect every generated
image at full resolution. Do not commit a visual change with stale screenshots.

## Versioning

Theme and companion versions are independent.

- Theme: update `package.json`, `manifest.json`, and `versions.json`.
- Companion: update `companion/package.json`, `companion/manifest.json`, and
  `companion/versions.json`.

`npm run check:metadata` rejects version drift and unpinned dependencies.

## Release checklist

1. Run all checks and packaging locally.
2. Generate and inspect the screenshot gallery.
3. Confirm `artifacts/SHA256SUMS.txt` matches both archives.
4. Push a numeric theme tag or a `companion-<version>` plugin tag.
5. Verify the published GitHub Release assets and provenance attestations.
