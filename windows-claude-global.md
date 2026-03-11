# MADZINE Claude Code (Windows)

## Language & Style

- Use Traditional Chinese
- No emojis
- Do not display code in conversation, describe approach only
- Write code only when editing files
- Minimal style, avoid lengthy explanations

## Prohibited Operations

- NEVER read image files with the Read tool (.img, .png, .jpg, .jpeg, .gif, .bmp, .webp, .svg, .ico, etc.)
- Use Bash tools (file, wc, xxd) to inspect image files without returning raw image data

## Response Principles

- When the user asks a question, answer first, do not implement until explicitly instructed

## Working Mode

- Prefer Plan Mode (EnterPlanMode) first
- Use AskUserQuestion to confirm requirements
- Use specialized Agents for complex tasks

## Reference Projects

Overview: %USERPROFILE%\Documents\MADZINE_Projects_Overview.md

### Windows Development Focus

| Language | Projects |
|----------|----------|
| Rust | WAAASAABIII, VideoMixerRust |
| C++17/20 | MADZINE-VCV (cross-compile), JUCE apps |

## Windows Environment

- OS: Windows 10/11
- Shell: PowerShell
- Editor: VS Code + Claude Code
- C++ Toolchain: MSVC (Visual Studio Build Tools 2022)
- Rust Toolchain: rustup (stable-x86_64-pc-windows-msvc)
- Package Manager: vcpkg (at %USERPROFILE%\Documents\Tools\vcpkg)
- Environment Variables:
  - VCPKG_ROOT = %USERPROFILE%\Documents\Tools\vcpkg
  - VCPKG_DEFAULT_TRIPLET = x64-windows
  - FFMPEG_DIR = %VCPKG_ROOT%\installed\x64-windows

## Folder Structure

```
%USERPROFILE%\Documents\
├── Commercial\          # Proprietary projects (Windows-compatible only)
├── OpenSource\          # Open source projects
│   └── WAAASAABIII\     # Rust multi-video player
├── Research\
└── Tools\
    └── vcpkg\           # C/C++ package manager
```

## Build Commands

### WAAASAABIII (Rust)

```powershell
cd $env:USERPROFILE\Documents\OpenSource\WAAASAABIII
cargo build --release
```

## Cross-Platform Sync

- All code syncs via GitHub (github.com/mmmmmmmadman)
- macOS is the primary development machine
- Windows for Windows-specific builds and testing
- Never force-push; always pull before work
