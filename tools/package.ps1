[CmdletBinding()]
param(
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$distRoot = Join-Path $repoRoot "dist"

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
$themeSource = Join-Path $distRoot "theme"

if (-not (Test-Path -LiteralPath (Join-Path $themeSource "theme.css"))) {
  throw "Built theme is missing. Run npm run build first."
}

$archiveName = "Claude-$($themeManifest.version).tar.gz"
$archivePath = Join-Path $distRoot $archiveName
$stagingRoot = Join-Path $distRoot ".package-$($themeManifest.version)"

if (Test-Path -LiteralPath $stagingRoot) {
  $resolvedStaging = (Resolve-Path -LiteralPath $stagingRoot).Path
  if (-not $resolvedStaging.StartsWith($distRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove package staging outside dist/."
  }
  Remove-Item -LiteralPath $resolvedStaging -Recurse -Force
}

New-Item -ItemType Directory -Path $stagingRoot | Out-Null

try {
  Copy-Item -LiteralPath (Join-Path $themeSource "manifest.json") -Destination (Join-Path $stagingRoot "manifest.json")
  Copy-Item -LiteralPath (Join-Path $themeSource "theme.css") -Destination (Join-Path $stagingRoot "theme.css")
  Copy-Item -LiteralPath (Join-Path $repoRoot "README.md") -Destination (Join-Path $stagingRoot "README.md")
  Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE") -Destination (Join-Path $stagingRoot "LICENSE")
  Copy-Item -LiteralPath (Join-Path $repoRoot "assets/fonts/licenses") -Destination (Join-Path $stagingRoot "font-licenses") -Recurse

  & tar -czf $archivePath -C $stagingRoot theme.css manifest.json README.md LICENSE font-licenses
  if ($LASTEXITCODE -ne 0) { throw "tar failed with exit code $LASTEXITCODE." }

  $archiveEntries = & tar -tzf $archivePath
  if ($LASTEXITCODE -ne 0) { throw "tar validation failed with exit code $LASTEXITCODE." }
  $requiredEntries = @("theme.css", "manifest.json", "README.md", "LICENSE", "font-licenses/")
  foreach ($entry in $requiredEntries) {
    if ($archiveEntries -notcontains $entry) { throw "Archive is missing $entry." }
  }
}
finally {
  if (Test-Path -LiteralPath $stagingRoot) {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
  }
}

Write-Output "Created release artifacts:"
Write-Output "- dist/theme/manifest.json"
Write-Output "- dist/theme/theme.css"
Write-Output "- dist/$archiveName"
