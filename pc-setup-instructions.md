# PC Setup Instructions (for Claude Code)

Read this file, then execute all steps below in order. Use PowerShell commands via the Bash tool. Report progress after each section. If any step fails, stop and ask the user.

## 1. Folder structure

Create these folders under `$env:USERPROFILE\Documents` if they don't exist:
- Commercial
- OpenSource
- Research
- Tools

## 2. Install prerequisites (via winget)

Check and install if missing:

| Tool | Check command | Install command |
|------|--------------|-----------------|
| Git | `git --version` | `winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements` |
| Rust | `rustup --version` | `winget install --id Rustlang.Rustup -e --accept-source-agreements --accept-package-agreements` |
| MSVC Build Tools | Check if `vswhere.exe` finds an installation | `winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-source-agreements --accept-package-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22621"` |

After installing, refresh PATH:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
```

## 3. vcpkg

```powershell
$vcpkgRoot = "$env:USERPROFILE\Documents\Tools\vcpkg"
```

If `$vcpkgRoot` doesn't exist:
1. `git clone https://github.com/microsoft/vcpkg.git $vcpkgRoot`
2. Run `$vcpkgRoot\bootstrap-vcpkg.bat -disableMetrics`

Set persistent environment variables (user scope):
```powershell
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgRoot, "User")
[System.Environment]::SetEnvironmentVariable("VCPKG_DEFAULT_TRIPLET", "x64-windows", "User")
```

Install packages:
```powershell
& "$vcpkgRoot\vcpkg.exe" install ffmpeg:x64-windows --recurse
& "$vcpkgRoot\vcpkg.exe" install rtaudio:x64-windows
```

Set FFMPEG_DIR:
```powershell
[System.Environment]::SetEnvironmentVariable("FFMPEG_DIR", "$vcpkgRoot\installed\x64-windows", "User")
```

## 4. Clone repos

Clone to `$env:USERPROFILE\Documents\OpenSource\` if not already there:

| Repo | URL |
|------|-----|
| WAAASAABIII | https://github.com/mmmmmmmadman/WAAASAABIII.git |

## 5. Claude Code config

Source: this repo (`madzine-dev-setup`). If not already cloned locally, clone it first:
```
git clone https://github.com/mmmmmmmadman/madzine-dev-setup.git "$env:USERPROFILE\Documents\OpenSource\madzine-dev-setup"
```

Then copy these to `$env:USERPROFILE\.claude\`:

| Source (relative to repo root) | Destination |
|------|-------------|
| `windows-claude-global.md` | `$env:USERPROFILE\.claude\CLAUDE.md` |
| `claude-config\agents\*` | `$env:USERPROFILE\.claude\agents\` |
| `claude-config\commands\*` | `$env:USERPROFILE\.claude\commands\` |

Create destination directories if they don't exist.

## 6. Verify

After all steps, print a summary:
- Which tools were already installed vs newly installed
- Which repos were already cloned vs newly cloned
- How many agents and commands were copied
- List the environment variables that were set
