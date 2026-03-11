# madzine-dev-setup

Windows development environment auto-setup for MADZINE projects.

## Contents

| File / Directory | Purpose |
|------|---------|
| setup-windows.ps1 | PowerShell setup script (folders, tools, repos, env vars, Claude config) |
| windows-claude-global.md | Global CLAUDE.md for Windows Claude Code |
| claude-config/agents/ | 19 custom agent definitions (synced from macOS) |
| claude-config/commands/ | 4 custom skill/command definitions (synced from macOS) |

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
6. Installs Claude Code config to ~/.claude/ (CLAUDE.md + agents + commands)
