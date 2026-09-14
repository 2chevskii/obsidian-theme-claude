[CmdletBinding()]
param(
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$distRoot = Join-Path $repoRoot "dist"
$artifactsRoot = Join-Path $repoRoot "artifacts"

if (-not $SkipBuild) {
  Push-Location $repoRoot
  try {
    & npm run build
    if ($LASTEXITCODE -ne 0) { throw "npm run build failed with exit code $LASTEXITCODE." }
  }
  finally {
    Pop-Location
  }
}

$themeManifest = Get-Content -Raw (Join-Path $repoRoot "manifest.json") | ConvertFrom-Json
$themeSource = Join-Path $distRoot "theme/Claude"

if (-not (Test-Path -LiteralPath (Join-Path $themeSource "theme.css"))) {
  throw "Built theme is missing. Run npm run build first."
}

if (Test-Path -LiteralPath $artifactsRoot) {
  $resolvedArtifacts = (Resolve-Path -LiteralPath $artifactsRoot).Path
  if (-not $resolvedArtifacts.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove artifacts outside the repository."
  }
  Remove-Item -LiteralPath $resolvedArtifacts -Recurse -Force
}

New-Item -ItemType Directory -Path $artifactsRoot, (Join-Path $artifactsRoot "theme") | Out-Null

Copy-Item -LiteralPath (Join-Path $themeSource "manifest.json") -Destination (Join-Path $artifactsRoot "theme") -Force
Copy-Item -LiteralPath (Join-Path $themeSource "theme.css") -Destination (Join-Path $artifactsRoot "theme") -Force

$themeArchive = Join-Path $artifactsRoot "claude-theme-$($themeManifest.version).zip"
Compress-Archive -LiteralPath $themeSource -DestinationPath $themeArchive -CompressionLevel Optimal

$checksumLines = Get-ChildItem -LiteralPath $artifactsRoot -File -Filter "*.zip" |
  Sort-Object Name |
  ForEach-Object {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
    "$hash  $($_.Name)"
  }
Set-Content -LiteralPath (Join-Path $artifactsRoot "SHA256SUMS.txt") -Value $checksumLines -Encoding utf8NoBOM

Write-Output "Created release artifacts:"
Get-ChildItem -LiteralPath $artifactsRoot -Recurse -File | ForEach-Object {
  Write-Output "- $($_.FullName.Substring($repoRoot.Length + 1))"
}
