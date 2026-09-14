[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$VaultName,

  [string]$OutputDirectory = (Join-Path $PSScriptRoot "../../screenshots"),

  [switch]$KeepFixture
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
$builtThemeRoot = Join-Path $repoRoot "dist/theme/Claude"
$themeCssSource = if (Test-Path -LiteralPath (Join-Path $builtThemeRoot "theme.css")) {
  Join-Path $builtThemeRoot "theme.css"
} else {
  Join-Path $repoRoot "theme.css"
}
$themeManifestSource = if (Test-Path -LiteralPath (Join-Path $builtThemeRoot "manifest.json")) {
  Join-Path $builtThemeRoot "manifest.json"
} else {
  Join-Path $repoRoot "manifest.json"
}
$backupRoot = Join-Path ([IO.Path]::GetTempPath()) "claude-theme-gallery-$([Guid]::NewGuid().ToString("N"))"
$fixtureRelativePath = "_claude-theme-gallery/claude-theme-showcase.md"
$debugAttached = $false
$themeInstalledBefore = $false
$fixtureCreated = $false
$fixtureExistedBefore = $false
$fixtureFolderExistedBefore = $false

function Invoke-Obsidian {
  param(
    [Parameter(Mandatory)]
    [string[]]$Arguments,
    [switch]$AllowFailure
  )

  $output = & rtk obsidian @Arguments "vault=$VaultName" 2>&1
  if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) {
    throw "Obsidian CLI failed: obsidian $($Arguments -join " ")`n$($output -join "`n")"
  }
  return ($output -join "`n").Trim()
}

function Invoke-Eval {
  param([Parameter(Mandatory)][string]$Code)
  return Invoke-Obsidian -Arguments @("eval", "code=$Code")
}

function ConvertFrom-EvalJson {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
  $normalized = (($Value -split "`r?`n") | Where-Object { $_ -notmatch '^\[rtk\]' } | Select-Object -Last 1).Trim()
  $normalized = $normalized -replace '^=>\s*', ''
  if ($normalized -in @("undefined", "null", "")) { return $null }
  try { return $normalized | ConvertFrom-Json }
  catch { return $normalized.Trim('"') }
}

function Set-ColorMode {
  param([ValidateSet("light", "dark")][string]$Mode)
  $current = ConvertFrom-EvalJson (Invoke-Eval "document.body.classList.contains('theme-dark') ? 'dark' : 'light'")
  if ($current -ne $Mode) {
    Invoke-Obsidian -Arguments @("command", "id=theme:toggle-light-dark") | Out-Null
    Start-Sleep -Milliseconds 450
  }
}

function Set-LightPalette {
  param([ValidateSet("default", "warm")][string]$Palette)
  $className = "claude-light-palette-$Palette"
  $code = "document.body.classList.remove('claude-light-palette-default','claude-light-palette-warm');document.body.classList.add('$className');true"
  Invoke-Eval $code | Out-Null
  Start-Sleep -Milliseconds 300
}

function Close-Overlay {
  Invoke-Obsidian -Arguments @(
    "dev:cdp",
    "method=Input.dispatchKeyEvent",
    'params={"type":"keyDown","key":"Escape","code":"Escape","windowsVirtualKeyCode":27}'
  ) -AllowFailure | Out-Null
  Invoke-Obsidian -Arguments @(
    "dev:cdp",
    "method=Input.dispatchKeyEvent",
    'params={"type":"keyUp","key":"Escape","code":"Escape","windowsVirtualKeyCode":27}'
  ) -AllowFailure | Out-Null
  Start-Sleep -Milliseconds 300
}

function Save-Screenshot {
  param([Parameter(Mandatory)][string]$Name)
  $path = Join-Path $outputRoot $Name
  Invoke-Obsidian -Arguments @("dev:screenshot", "path=$path") | Out-Null
  if (-not (Test-Path -LiteralPath $path)) { throw "Screenshot was not created: $path" }
  return $path
}

function Set-PromptQuery {
  param([Parameter(Mandatory)][string]$Query)
  $escaped = $Query.Replace("\\", "\\\\").Replace("'", "\\'")
  $code = "(()=>{const input=document.querySelector('.prompt-input');if(!input)return false;input.value='$escaped';input.dispatchEvent(new InputEvent('input',{bubbles:true,inputType:'insertText',data:'$escaped'}));return true})()"
  $result = ConvertFrom-EvalJson (Invoke-Eval $code)
  if ($result -ne $true) { throw "Prompt input was not found." }
  Start-Sleep -Milliseconds 650
}

function New-Thumbnail {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Destination
  )

  Add-Type -AssemblyName System.Drawing
  $image = [Drawing.Image]::FromFile($Source)
  try {
    $targetWidth = 512
    $targetHeight = 288
    $targetRatio = $targetWidth / $targetHeight
    $sourceRatio = $image.Width / $image.Height
    if ($sourceRatio -gt $targetRatio) {
      $cropHeight = $image.Height
      $cropWidth = [int]($cropHeight * $targetRatio)
      $cropX = [int](($image.Width - $cropWidth) / 2)
      $cropY = 0
    }
    else {
      $cropWidth = $image.Width
      $cropHeight = [int]($cropWidth / $targetRatio)
      $cropX = 0
      $cropY = [int](($image.Height - $cropHeight) / 2)
    }

    $bitmap = [Drawing.Bitmap]::new($targetWidth, $targetHeight)
    try {
      $graphics = [Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage(
          $image,
          [Drawing.Rectangle]::new(0, 0, $targetWidth, $targetHeight),
          [Drawing.Rectangle]::new($cropX, $cropY, $cropWidth, $cropHeight),
          [Drawing.GraphicsUnit]::Pixel
        )
      }
      finally {
        $graphics.Dispose()
      }
      $bitmap.Save($Destination, [Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
      $bitmap.Dispose()
    }
  }
  finally {
    $image.Dispose()
  }
}

$vaultPath = (Invoke-Obsidian -Arguments @("vault", "info=path")).Trim()
if (-not (Test-Path -LiteralPath $vaultPath -PathType Container)) {
  throw "Vault path returned by Obsidian CLI does not exist: $vaultPath"
}

$themeTarget = Join-Path $vaultPath ".obsidian/themes/Claude"
$fixtureTarget = Join-Path $vaultPath $fixtureRelativePath
$fixtureFolder = Split-Path $fixtureTarget
$fixtureFolderExistedBefore = Test-Path -LiteralPath $fixtureFolder
$previousTheme = ConvertFrom-EvalJson (Invoke-Eval "app.vault.getConfig('cssTheme') ?? ''")
$previousMode = ConvertFrom-EvalJson (Invoke-Eval "document.body.classList.contains('theme-dark') ? 'dark' : 'light'")
$previousLightPalette = ConvertFrom-EvalJson (Invoke-Eval "document.body.classList.contains('claude-light-palette-warm') ? 'warm' : 'default'")
$previousFile = ConvertFrom-EvalJson (Invoke-Eval "app.workspace.getActiveFile()?.path ?? ''")

try {
  New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
  New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

  if (Test-Path -LiteralPath $themeTarget) {
    $themeInstalledBefore = $true
    Copy-Item -LiteralPath $themeTarget -Destination (Join-Path $backupRoot "Claude") -Recurse
  }
  if (Test-Path -LiteralPath $fixtureTarget) {
    $fixtureExistedBefore = $true
    Copy-Item -LiteralPath $fixtureTarget -Destination (Join-Path $backupRoot "claude-theme-showcase.md")
  }

  New-Item -ItemType Directory -Path $themeTarget, $fixtureFolder -Force | Out-Null
  Copy-Item -LiteralPath $themeCssSource -Destination (Join-Path $themeTarget "theme.css") -Force
  Copy-Item -LiteralPath $themeManifestSource -Destination (Join-Path $themeTarget "manifest.json") -Force
  if ($themeCssSource -eq (Join-Path $repoRoot "theme.css")) {
    Copy-Item -LiteralPath (Join-Path $repoRoot "fonts") -Destination $themeTarget -Recurse -Force
  }
  Copy-Item -LiteralPath (Join-Path $repoRoot "tools/gallery/showcase.md") -Destination $fixtureTarget -Force
  $fixtureCreated = $true

  Invoke-Obsidian -Arguments @("theme:set", "name=Claude") | Out-Null
  Invoke-Obsidian -Arguments @("open", "path=$fixtureRelativePath") | Out-Null
  Invoke-Obsidian -Arguments @("dev:debug", "on") | Out-Null
  $debugAttached = $true
  Start-Sleep -Milliseconds 900

  Close-Overlay
  Invoke-Obsidian -Arguments @("open", "path=$fixtureRelativePath") | Out-Null
  Invoke-Eval "document.querySelector('.workspace-leaf.mod-active .cm-scroller')?.scrollTo(0,0);true" | Out-Null
  Set-ColorMode light
  Set-LightPalette default
  $lightOverview = Save-Screenshot "overview-light.png"

  Set-LightPalette warm
  Save-Screenshot "overview-warm.png" | Out-Null
  Set-LightPalette default

  Set-ColorMode dark
  Save-Screenshot "overview-dark.png" | Out-Null

  Set-ColorMode light
  $editorCode = "(()=>{const editor=app.workspace.activeLeaf?.view?.editor;const line=editor?.getValue().split(String.fromCharCode(10)).findIndex(x=>x.startsWith('## Typography'))??-1;if(!editor||line<0)return false;editor.setCursor({line,ch:3});editor.focus();return true})()"
  Invoke-Eval $editorCode | Out-Null
  Start-Sleep -Milliseconds 350
  Save-Screenshot "live-preview-headings-light.png" | Out-Null

  Invoke-Obsidian -Arguments @("command", "id=switcher:open") | Out-Null
  Start-Sleep -Milliseconds 250
  Set-PromptQuery "claude-theme-showcase"
  Save-Screenshot "quick-switcher-light.png" | Out-Null
  Close-Overlay

  Set-ColorMode dark
  Invoke-Obsidian -Arguments @("command", "id=command-palette:open") | Out-Null
  Start-Sleep -Milliseconds 250
  Set-PromptQuery "theme"
  Save-Screenshot "command-palette-dark.png" | Out-Null
  Close-Overlay

  Set-ColorMode light
  Invoke-Eval "app.setting.open();app.setting.openTabById('obsidian-style-settings');true" | Out-Null
  Start-Sleep -Milliseconds 700
  Invoke-Eval "const heading=document.querySelector('.style-settings-heading[data-id=claude-theme].is-collapsed');if(heading)heading.click();true" | Out-Null
  Start-Sleep -Milliseconds 350
  Save-Screenshot "style-settings-light.png" | Out-Null
  Close-Overlay

  Save-Screenshot "status-bar-light.png" | Out-Null

  New-Thumbnail -Source $lightOverview -Destination (Join-Path $outputRoot "theme-thumbnail.png")
  Write-Output "Gallery generated at $outputRoot"
}
finally {
  if ($debugAttached) {
    try { Invoke-Obsidian -Arguments @("dev:debug", "off") -AllowFailure | Out-Null }
    catch { Write-Warning "Could not detach Obsidian debugger: $_" }
  }
  if ($fixtureCreated -and -not $KeepFixture -and -not $fixtureExistedBefore) {
    try { Invoke-Obsidian -Arguments @("delete", "path=$fixtureRelativePath") -AllowFailure | Out-Null }
    catch { Write-Warning "Could not move the gallery fixture to trash: $_" }
  }

  foreach ($target in @($themeTarget)) {
    if (Test-Path -LiteralPath $target) {
      $resolvedTarget = (Resolve-Path -LiteralPath $target).Path
      $expectedRoot = (Resolve-Path -LiteralPath (Join-Path $vaultPath ".obsidian")).Path
      if (-not $resolvedTarget.StartsWith($expectedRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to restore an extension outside the vault configuration folder."
      }
      Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
    }
  }
  if ($themeInstalledBefore) {
    Move-Item -LiteralPath (Join-Path $backupRoot "Claude") -Destination $themeTarget
  }
  if ($fixtureExistedBefore -and -not $KeepFixture) {
    Copy-Item -LiteralPath (Join-Path $backupRoot "claude-theme-showcase.md") -Destination $fixtureTarget -Force
  }
  if (-not $KeepFixture -and -not $fixtureFolderExistedBefore -and (Test-Path -LiteralPath $fixtureFolder)) {
    $remainingFixtureEntries = @(Get-ChildItem -LiteralPath $fixtureFolder -Force)
    if ($remainingFixtureEntries.Count -eq 0) {
      Remove-Item -LiteralPath $fixtureFolder -Force
    }
  }
  if ($previousTheme -ne $null) {
    try { Invoke-Obsidian -Arguments @("theme:set", "name=$previousTheme") -AllowFailure | Out-Null }
    catch { Write-Warning "Could not restore the previous theme: $_" }
  }
  if ($previousMode) {
    try { Set-ColorMode $previousMode }
    catch { Write-Warning "Could not restore the previous color mode: $_" }
  }
  if ($previousLightPalette) {
    try { Set-LightPalette $previousLightPalette }
    catch { Write-Warning "Could not restore the previous light palette: $_" }
  }
  if ($previousFile) {
    try { Invoke-Obsidian -Arguments @("open", "path=$previousFile") -AllowFailure | Out-Null }
    catch { Write-Warning "Could not reopen the previous file: $_" }
  }
  if (Test-Path -LiteralPath $backupRoot) {
    Remove-Item -LiteralPath $backupRoot -Recurse -Force
  }
}
