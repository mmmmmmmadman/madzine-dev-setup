# Sync Claude Config to PC (for Claude Code)

Read this file, then execute all steps below. Use PowerShell commands via the Bash tool.

## 1. Pull latest

```powershell
$repoDir = "$env:USERPROFILE\Documents\OpenSource\madzine-dev-setup"
```

If `$repoDir` doesn't exist, clone it first:
```powershell
git clone https://github.com/mmmmmmmadman/madzine-dev-setup.git $repoDir
```

If it exists, pull:
```powershell
git -C $repoDir pull
```

## 2. Copy to ~/.claude/

Create directories if they don't exist, then copy:

| Source (relative to repo root) | Destination |
|------|-------------|
| `windows-claude-global.md` | `$env:USERPROFILE\.claude\CLAUDE.md` |
| `claude-config\agents\*` (including subdirectories) | `$env:USERPROFILE\.claude\agents\` |
| `claude-config\commands\*` | `$env:USERPROFILE\.claude\commands\` |

Use `-Recurse -Force` to overwrite existing files and include subdirectories.

## 3. Report

Print:
- How many agent files were copied
- How many command files were copied
- Confirm CLAUDE.md was updated
