# Contributing

## Local checks

Use Node.js 24 and install the exact dependency graph from `package-lock.json`.

```powershell
rtk pwsh -NoProfile -Command 'rtk fnm use --silent-if-unchanged; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; rtk npm ci'
rtk pwsh -NoProfile -Command 'rtk fnm use --silent-if-unchanged; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; rtk npm run check'
```

Run `npm run gallery` after visual changes and inspect every generated image at full
resolution. The container is the only supported screenshot renderer; it runs an isolated,
real Obsidian process under Xvfb. Do not commit visual changes with stale screenshots.

## Versioning

For each release, update `package.json` and `manifest.json` to the same
Semantic Versioning value, then add the corresponding minimum Obsidian version
to `versions.json`.

## Release checklist

1. Run `npm run check` locally.
2. Run `npm run gallery`, then inspect the regenerated screenshots.
3. Push a numeric tag matching `manifest.json`.
4. Verify that GitHub Actions created a draft release with `manifest.json` and
   `theme.css`.
5. Add release notes, publish the draft, and verify the release assets.
