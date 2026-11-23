# MADZINE Windows Development Environment Setup
# Usage: powershell -ExecutionPolicy Bypass -File setup-windows.ps1
# Requires: Windows 10/11 with winget

param(
    [string]$DocsRoot = "$env:USERPROFILE\Documents"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Step { param([string]$msg) Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-OK   { param([string]$msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip { param([string]$msg) Write-Host "  [SKIP] $msg" -ForegroundColor Yellow }

# --------------------------------------------------
# 1. Folder structure
# --------------------------------------------------
Write-Step "Creating folder structure under $DocsRoot"

$folders = @("Commercial", "OpenSource", "Research", "Tools")
foreach ($f in $folders) {
    $path = Join-Path $DocsRoot $f
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-OK "Created $f\"
    } else {
        Write-Skip "$f\ already exists"
    }
}

# --------------------------------------------------
# 2. Prerequisites check & install
# --------------------------------------------------
Write-Step "Checking prerequisites"

# Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-OK "Git $(git --version)"
} else {
    Write-Host "  Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-OK "Git installed"
}

# Rust
if (Get-Command rustup -ErrorAction SilentlyContinue) {
    Write-OK "Rust $(rustc --version)"
} else {
    Write-Host "  Installing Rust..." -ForegroundColor Yellow
    winget install --id Rustlang.Rustup -e --accept-source-agreements --accept-package-agreements
    $env:Path += ";$env:USERPROFILE\.cargo\bin"
    Write-OK "Rust installed"
}

# MSVC Build Tools (check for cl.exe)
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsWhere) {
    $vsPath = & $vsWhere -latest -property installationPath 2>$null
    if ($vsPath) {
        Write-OK "MSVC Build Tools found at $vsPath"
    } else {
        Write-Host "  Installing MSVC Build Tools..." -ForegroundColor Yellow
        winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-source-agreements --accept-package-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22621"
        Write-OK "MSVC Build Tools installed"
    }
} else {
    Write-Host "  Installing MSVC Build Tools..." -ForegroundColor Yellow
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-source-agreements --accept-package-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22621"
    Write-OK "MSVC Build Tools installed"
}

# --------------------------------------------------
# 3. vcpkg setup
# --------------------------------------------------
Write-Step "Setting up vcpkg"

$vcpkgRoot = Join-Path $DocsRoot "Tools\vcpkg"
if (-not (Test-Path $vcpkgRoot)) {
    git clone https://github.com/microsoft/vcpkg.git $vcpkgRoot
    & "$vcpkgRoot\bootstrap-vcpkg.bat" -disableMetrics
    Write-OK "vcpkg bootstrapped"
} else {
    Write-Skip "vcpkg already exists"
}

# Set environment variables (user scope, persistent)
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgRoot, "User")
[System.Environment]::SetEnvironmentVariable("VCPKG_DEFAULT_TRIPLET", "x64-windows", "User")
$env:VCPKG_ROOT = $vcpkgRoot
$env:VCPKG_DEFAULT_TRIPLET = "x64-windows"

# Install WAAASAABIII dependencies via vcpkg
Write-Step "Installing vcpkg packages (ffmpeg, rtaudio)"

$vcpkg = Join-Path $vcpkgRoot "vcpkg.exe"
& $vcpkg install ffmpeg:x64-windows --recurse 2>&1 | Select-Object -Last 3
Write-OK "ffmpeg installed"

& $vcpkg install rtaudio:x64-windows 2>&1 | Select-Object -Last 3
Write-OK "rtaudio installed"

# Set FFMPEG_DIR for ffmpeg-next crate
$ffmpegDir = Join-Path $vcpkgRoot "installed\x64-windows"
[System.Environment]::SetEnvironmentVariable("FFMPEG_DIR", $ffmpegDir, "User")
$env:FFMPEG_DIR = $ffmpegDir
Write-OK "FFMPEG_DIR = $ffmpegDir"

# --------------------------------------------------
# 4. Clone repos
# --------------------------------------------------
Write-Step "Cloning repositories"

$repos = @{
    "OpenSource\WAAASAABIII" = "https://github.com/mmmmmmmadman/WAAASAABIII.git"
}

foreach ($entry in $repos.GetEnumerator()) {
    $dest = Join-Path $DocsRoot $entry.Key
    if (-not (Test-Path $dest)) {
        git clone $entry.Value $dest
        Write-OK "Cloned $($entry.Key)"
    } else {
        Write-Skip "$($entry.Key) already exists"
    }
}

# --------------------------------------------------
# 5. HORITOMO 3D (Python 3.14 + ffmpeg + private repo + venv)
# --------------------------------------------------
Write-Step "Setting up HORITOMO 3D"

# Python 3.14 (per-user install, same as setup_venv.ps1 looks for first)
$py314User = Join-Path $env:LOCALAPPDATA "Programs\Python\Python314\python.exe"
$py314Machine = Join-Path $env:ProgramFiles "Python314\python.exe"
if ((Test-Path $py314User) -or (Test-Path $py314Machine)) {
    Write-OK "Python 3.14 found"
} else {
    Write-Host "  Installing Python 3.14..." -ForegroundColor Yellow
    winget install --id Python.Python.3.14 -e --scope user --accept-source-agreements --accept-package-agreements
    Write-OK "Python 3.14 installed"
}

# ffmpeg executable (Gyan build via winget; separate from the vcpkg ffmpeg libraries above)
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    Write-OK "ffmpeg found at $((Get-Command ffmpeg).Source)"
} else {
    Write-Host "  Installing ffmpeg (Gyan.FFmpeg)..." -ForegroundColor Yellow
    winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-OK "ffmpeg installed"
}

# Clone HORITOMO_3D (PRIVATE repo: unlike WAAASAABIII, git asks for GitHub credentials;
# Git for Windows' Credential Manager opens a browser sign-in on first use)
$horitomoDir = Join-Path $DocsRoot "Research\HORITOMO_3D"
$horitomoOk = $true
if (-not (Test-Path $horitomoDir)) {
    Write-Host "  HORITOMO_3D is a private repo. Sign in to GitHub (mmmmmmmadman) if prompted." -ForegroundColor Yellow
    git clone https://github.com/mmmmmmmadman/HORITOMO_3D.git $horitomoDir
    if ($LASTEXITCODE -eq 0) {
        Write-OK "Cloned Research\HORITOMO_3D"
    } else {
        $horitomoOk = $false
        Write-Host "  [FAIL] git clone HORITOMO_3D failed (credentials?). Skipping venv setup." -ForegroundColor Red
    }
} else {
    Write-Skip "Research\HORITOMO_3D already exists"
}

# Python venv (animation\setup_venv.ps1 is idempotent; run as a child process because it calls exit)
if ($horitomoOk) {
    $horitomoVenvScript = Join-Path $horitomoDir "animation\setup_venv.ps1"
    if (Test-Path $horitomoVenvScript) {
        powershell -NoProfile -ExecutionPolicy Bypass -File $horitomoVenvScript
        if ($LASTEXITCODE -eq 0) {
            Write-OK "HORITOMO venv ready"
        } else {
            Write-Host "  [FAIL] HORITOMO setup_venv.ps1 failed (exit $LASTEXITCODE)" -ForegroundColor Red
        }
    } else {
        Write-Skip "animation\setup_venv.ps1 not found, skipping venv"
    }
}

Write-Host "  NOTE: HORITOMO scene data (animation\work\ scene folders, Dropbox material) is not in git." -ForegroundColor Yellow
Write-Host "        Copy it from the Mac manually." -ForegroundColor Yellow

# --------------------------------------------------
# 6. Claude Code config (CLAUDE.md + agents + commands)
# --------------------------------------------------
Write-Step "Setting up Claude Code config"

$claudeDir = Join-Path $env:USERPROFILE ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

# Global CLAUDE.md
$claudeMdSrc = Join-Path $PSScriptRoot "windows-claude-global.md"
$claudeMdDst = Join-Path $claudeDir "CLAUDE.md"

if (Test-Path $claudeMdSrc) {
    Copy-Item $claudeMdSrc $claudeMdDst -Force
    Write-OK "Global CLAUDE.md installed"
} else {
    Write-Skip "windows-claude-global.md not found, skipping"
}

# Agents
$agentsSrc = Join-Path $PSScriptRoot "claude-config\agents"
$agentsDst = Join-Path $claudeDir "agents"
if (Test-Path $agentsSrc) {
    if (-not (Test-Path $agentsDst)) {
        New-Item -ItemType Directory -Path $agentsDst -Force | Out-Null
    }
    Copy-Item "$agentsSrc\*" $agentsDst -Recurse -Force
    $agentCount = (Get-ChildItem $agentsDst -Filter "*.md" -File).Count
    Write-OK "$agentCount agents installed"
} else {
    Write-Skip "claude-config\agents not found, skipping"
}

# Commands (skills)
$cmdsSrc = Join-Path $PSScriptRoot "claude-config\commands"
$cmdsDst = Join-Path $claudeDir "commands"
if (Test-Path $cmdsSrc) {
    if (-not (Test-Path $cmdsDst)) {
        New-Item -ItemType Directory -Path $cmdsDst -Force | Out-Null
    }
    Copy-Item "$cmdsSrc\*" $cmdsDst -Recurse -Force
    $cmdCount = (Get-ChildItem $cmdsDst -Filter "*.md" -File).Count
    Write-OK "$cmdCount commands installed"
} else {
    Write-Skip "claude-config\commands not found, skipping"
}

# --------------------------------------------------
# 7. Summary
# --------------------------------------------------
Write-Step "Setup complete"

Write-Host ""
Write-Host "Folder structure:" -ForegroundColor White
Write-Host "  $DocsRoot\Commercial\"
Write-Host "  $DocsRoot\OpenSource\WAAASAABIII\"
Write-Host "  $DocsRoot\Research\"
Write-Host "  $DocsRoot\Research\HORITOMO_3D\"
Write-Host "  $DocsRoot\Tools\vcpkg\"
Write-Host ""
Write-Host "Environment variables (persistent, user scope):" -ForegroundColor White
Write-Host "  VCPKG_ROOT = $vcpkgRoot"
Write-Host "  VCPKG_DEFAULT_TRIPLET = x64-windows"
Write-Host "  FFMPEG_DIR = $ffmpegDir"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart terminal to load new environment variables"
Write-Host "  2. cd $DocsRoot\OpenSource\WAAASAABIII"
Write-Host "  3. cargo build"
Write-Host "  4. HORITOMO 3D: copy scene data (animation\work\, Dropbox material) from the Mac,"
Write-Host "     then run $DocsRoot\Research\HORITOMO_3D\animation\HORITOMO.bat"
Write-Host ""
