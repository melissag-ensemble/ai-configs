# Assumes this repo is cloned as a subfolder of the Projects root (ai-configs is NOT
# the Projects root itself on Windows, since CLAUDE.md/AGENTS.md are hardlinked up to
# it rather than living there directly - native symlinks need admin/Developer Mode).
$ScriptDir = $PSScriptRoot
$Root = Split-Path -Parent $ScriptDir

Write-Output "==> Pulling ai-configs (CLAUDE.md, AGENTS.md)..."
git -C "$ScriptDir" pull origin main

Write-Output "==> Pulling cursor rules (adp-devsite-cursor-rules)..."
git -C "$Root\adp-devsite-cursor-rules" pull

function Ensure-Junction($Path, $Target) {
    if (Test-Path $Path) {
        $item = Get-Item $Path -Force
        if ($item.LinkType) {
            Write-Output "    OK: $Path"
            return
        }
        Write-Output "    $Path exists but is not a link - leaving it alone."
        return
    }
    Write-Output "    Missing - creating junction at $Path -> $Target"
    cmd /c mklink /J "$Path" "$Target" | Out-Null
}

function Get-FileId($Path) {
    if (-not (Test-Path $Path)) { return $null }
    $raw = fsutil file queryfileid "$Path" 2>$null
    if (-not $raw) { return $null }
    return ($raw -split " " | Select-Object -Last 1)
}

function Sync-Hardlink($Path, $Target) {
    # `git pull` unlinks and recreates changed files rather than editing them in
    # place, which silently severs a hardlink (the two paths end up on different
    # NTFS File IDs with no error). So re-link unconditionally on every run instead
    # of only when $Path is missing.
    $pathId = Get-FileId $Path
    $targetId = Get-FileId $Target
    if ($pathId -and $pathId -eq $targetId) {
        Write-Output "    OK: $Path"
        return
    }
    if (Test-Path $Path) {
        Write-Output "    $Path was stale (hardlink broken by last pull) - relinking..."
        Remove-Item $Path -Force
    } else {
        Write-Output "    Missing - creating hardlink at $Path -> $Target"
    }
    cmd /c mklink /H "$Path" "$Target" | Out-Null
}

Write-Output "==> Checking CLAUDE.md / AGENTS.md hardlinks..."
Sync-Hardlink "$Root\CLAUDE.md" "$ScriptDir\CLAUDE.md"
Sync-Hardlink "$Root\AGENTS.md" "$ScriptDir\AGENTS.md"

Write-Output "==> Checking .cursor junction..."
Ensure-Junction "$Root\.cursor" "$Root\adp-devsite-cursor-rules\.cursor"

Write-Output "==> Checking .claude\commands junction..."
New-Item -ItemType Directory -Force -Path "$Root\.claude" | Out-Null
Ensure-Junction "$Root\.claude\commands" "$Root\adp-devsite-cursor-rules\.claude\commands"

Write-Output "==> Codex AGENTS.md refresh"
Write-Output "    If CLAUDE.md changed, run: ./refresh-agents.sh"

Write-Output ""
Write-Output "Done."
