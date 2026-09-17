# Real Obsidian gallery renderer

`npm run gallery` builds `dist/`, builds the pinned `linux/amd64` Docker image, and
captures the gallery through a real Obsidian desktop process under Xvfb. The host only
provides Docker; no host vault, Obsidian profile, display, fonts, or screenshots take part.

The renderer uses a copied fixture vault, `dist/` as the local Claude.md theme, and the
locally downloaded, checksum-verified Style Settings 1.0.9 assets. `renderer-lock.json`
pins the Docker image digest, Obsidian app/installer version, plugin assets, viewport, and
required scenario names. Update it deliberately when changing a renderer dependency.

## Commands

```powershell
rtk pwsh -NoProfile -Command 'rtk fnm use --silent-if-unchanged; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; rtk npm run gallery'
rtk pwsh -NoProfile -Command 'rtk fnm use --silent-if-unchanged; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; rtk npm run gallery:verify'
```

`gallery:verify` checks the scenario manifest, PNG signatures and dimensions, and every
image reference in `assets/screenshots/README.md`. CI additionally fails when a regenerated
gallery differs from the tracked images.

The container runs as an unprivileged `gallery` user and does not use `--no-sandbox`.
