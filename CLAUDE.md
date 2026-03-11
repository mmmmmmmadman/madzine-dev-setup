# madzine-dev-setup

Windows development environment auto-setup for MADZINE projects.

## Contents

| File | Purpose |
|------|---------|
| setup-windows.ps1 | PowerShell setup script (folders, tools, repos, env vars) |
| windows-claude-global.md | Global CLAUDE.md for Windows Claude Code |

## Usage

```powershell
git clone https://github.com/mmmmmmmadman/madzine-dev-setup.git
cd madzine-dev-setup
powershell -ExecutionPolicy Bypass -File setup-windows.ps1
```

## What it does

1. Creates Documents folder structure (Commercial, OpenSource, Research, Tools)
2. Checks/installs Git, Rust, MSVC Build Tools via winget
3. Bootstraps vcpkg and installs ffmpeg + rtaudio
4. Clones WAAASAABIII from GitHub
5. Sets persistent environment variables (VCPKG_ROOT, FFMPEG_DIR)
6. Copies windows-claude-global.md to ~/.claude/CLAUDE.md
