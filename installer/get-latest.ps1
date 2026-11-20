# Downloads the newest SpaghettiKart LAN8 build from GitHub and installs it
# into -InstallDir. Run by the setup (and by "Check for updates").
#
# The build lives on the repo's `latest-build` branch as
# SpaghettiKart-LAN8-Windows.zip plus version.txt.
#
# Exit codes: 0 ok, 2 download failed, 3 bad zip, 4 game is running, 5 copy failed.

param(
    [Parameter(Mandatory = $true)][string]$InstallDir,
    [string]$Repo = "T3chnobone/Spaghettikart-8-Player-with-Lan",
    [string]$Branch = "latest-build",
    [string]$WorkDir = $env:TEMP
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # Invoke-WebRequest is very slow with the progress bar
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base = "https://raw.githubusercontent.com/$Repo/$Branch"
$work = Join-Path $WorkDir ("sk-lan8-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $work | Out-Null

function Done($code, $msg) {
    if ($msg) { Write-Output $msg }
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $work
    exit $code
}

# --- the game must not be running (its files would be locked) ---
$exe = Join-Path $InstallDir "Spaghettify.exe"
$running = Get-Process -Name "Spaghettify" -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and ($_.Path -ieq $exe) }
if ($running) { Done 4 "The game is running. Close SpaghettiKart and try again." }

# --- download ---
$version = "unknown"
try {
    $version = (Invoke-WebRequest -UseBasicParsing -Uri "$base/version.txt").Content.Trim()
} catch { }
Write-Output "Newest build: $version"

$zip = Join-Path $work "game.zip"
try {
    Write-Output "Downloading $base/SpaghettiKart-LAN8-Windows.zip ..."
    Invoke-WebRequest -UseBasicParsing -Uri "$base/SpaghettiKart-LAN8-Windows.zip" -OutFile $zip
} catch {
    Done 2 ("Download failed: " + $_.Exception.Message)
}

# --- unpack and find the folder that holds Spaghettify.exe ---
$unz = Join-Path $work "unz"
try {
    Expand-Archive -LiteralPath $zip -DestinationPath $unz -Force
} catch {
    Done 3 ("The download isn't a valid zip: " + $_.Exception.Message)
}
$found = Get-ChildItem -LiteralPath $unz -Recurse -Filter "Spaghettify.exe" | Select-Object -First 1
if (-not $found) { Done 3 "The download has no Spaghettify.exe in it." }
$src = $found.DirectoryName

# --- copy into the install folder ---
# Files the player may have changed are only copied when missing.
$keepIfPresent = @(
    "spaghettify.cfg.json",
    "textures\couch_party_button.png",
    "textures\lan_game_button.png",
    "textures\character_highlight.png"
)
# Never shipped, never touched: mk64.o2r, leaderboards.json, logs\, mods\, saves.

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$manifest = New-Object System.Collections.Generic.List[string]
try {
    Get-ChildItem -LiteralPath $src -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($src.Length).TrimStart('\', '/')
        $dst = Join-Path $InstallDir $rel
        $manifest.Add($rel)
        if (($keepIfPresent -contains $rel) -and (Test-Path -LiteralPath $dst)) { return }
        $dir = Split-Path -Parent $dst
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Copy-Item -LiteralPath $_.FullName -Destination $dst -Force
    }
} catch {
    Done 5 ("Copying the game files failed: " + $_.Exception.Message)
}

# What the uninstaller removes, and which build is installed.
$manifest | Set-Content -LiteralPath (Join-Path $InstallDir "installed-files.txt") -Encoding ASCII
Set-Content -LiteralPath (Join-Path $InstallDir "version.txt") -Value $version -Encoding ASCII -NoNewline

Done 0 "Installed build $version ($($manifest.Count) files)."
