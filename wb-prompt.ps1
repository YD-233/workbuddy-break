# WorkBuddy Prompt Tool for Windows
# Extract, edit and inject WorkBuddy system prompt templates.
# Requires: Windows PowerShell 5.1+ or PowerShell 7, WorkBuddy installed and launched at least once.

$ErrorActionPreference = "Stop"

$WORK = Join-Path $env:USERPROFILE "Desktop\WorkBuddy-Prompts-Workspace"
$BACKUP_NAME = ".wb-prompt-original"

function Get-CacheRoot {
    $home = $env:USERPROFILE
    $candidates = @(
        (Join-Path $home ".workbuddy\plugins\cache\workbuddy-builtin"),
        (Join-Path $home ".workbuddy\plugins\cache")
    )
    foreach ($root in $candidates) {
        if (Test-Path $root) {
            $hit = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match '^(welcomemode|interactionmode)-' } | Select-Object -First 1
            if ($hit) { return $root }
        }
    }
    return $null
}

function Get-Targets([string]$root) {
    $list = @()
    if (-not $root -or -not (Test-Path $root)) { return $list }
    $modules = Get-ChildItem -Path $root -Directory | Where-Object { $_.Name -match '^(welcomemode|interactionmode)-' }
    foreach ($mod in $modules) {
        $versions = Get-ChildItem -Path $mod.FullName -Directory | Where-Object { -not $_.Name.StartsWith(".") }
        foreach ($ver in $versions) {
            if ($mod.Name.StartsWith("welcomemode-")) {
                $f = Join-Path $ver.FullName "prompt.tpl"
                if (Test-Path $f) { $list += (Join-Path $mod.Name (Join-Path $ver.Name "prompt.tpl")) }
            } else {
                $fd = Join-Path $ver.FullName "fragments"
                if (Test-Path $fd) {
                    Get-ChildItem -Path $fd -File -Filter "*.md" | ForEach-Object {
                        $list += (Join-Path $mod.Name (Join-Path $ver.Name (Join-Path "fragments" $_.Name)))
                    }
                }
            }
        }
    }
    return $list
}

function Copy-FileSafe([string]$src, [string]$dst) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -Path $src -Destination $dst -Force
}

function Get-AllFiles([string]$dir) {
    if (-not (Test-Path $dir)) { return @() }
    return @(Get-ChildItem -Path $dir -File -Recurse)
}

function Invoke-Extract {
    $root = Get-CacheRoot
    if (-not $root) {
        Write-Error "WorkBuddy plugin cache not found. Install and launch WorkBuddy at least once, then retry."
        exit 1
    }
    $targets = Get-Targets $root
    foreach ($rel in $targets) {
        Copy-FileSafe (Join-Path $root $rel) (Join-Path $WORK $rel)
    }
    Write-Host "Extracted $($targets.Count) template files to:"
    Write-Host "  $WORK"
    Write-Host "Edit prompt.tpl and fragments/*.md there, then run apply."
}

function Invoke-Apply {
    $root = Get-CacheRoot
    if (-not $root) {
        Write-Error "WorkBuddy plugin cache not found."
        exit 1
    }
    if (-not (Test-Path $WORK)) {
        Write-Error "Workspace not found: $WORK`nRun extract first."
        exit 1
    }
    $targets = Get-Targets $root
    $backup = Join-Path $root $BACKUP_NAME
    if (-not (Test-Path $backup)) {
        foreach ($rel in $targets) { Copy-FileSafe (Join-Path $root $rel) (Join-Path $backup $rel) }
        Write-Host "Official backup created at: $backup"
    }
    $files = Get-AllFiles $WORK
    $applied = 0
    $skipped = 0
    foreach ($file in $files) {
        $rel = $file.FullName.Substring($WORK.Length).TrimStart('\', '/')
        $dest = Join-Path $root $rel
        if (-not (Test-Path $dest)) {
            Write-Host "  Skip (no target in cache): $rel"
            $skipped++
            continue
        }
        Copy-Item -Path $file.FullName -Destination $dest -Force
        $applied++
    }
    Write-Host "Applied $applied file(s)" + $(if ($skipped) { ", skipped $skipped" } else { "" }) + "."
    Write-Host "Quit WorkBuddy completely, reopen it and start a NEW conversation to load the new prompt."
}

function Invoke-Restore {
    $root = Get-CacheRoot
    if (-not $root) {
        Write-Error "WorkBuddy plugin cache not found."
        exit 1
    }
    $backup = Join-Path $root $BACKUP_NAME
    if (-not (Test-Path $backup)) {
        Write-Error "Backup not found, cannot restore: $backup"
        exit 1
    }
    $files = Get-AllFiles $backup
    foreach ($file in $files) {
        $rel = $file.FullName.Substring($backup.Length).TrimStart('\', '/')
        Copy-FileSafe $file.FullName (Join-Path $root $rel)
    }
    Write-Host "Restored $($files.Count) file(s) to the official version."
    Write-Host "Restart WorkBuddy and start a new conversation to take effect."
}

function Invoke-Status {
    $root = Get-CacheRoot
    $rootText = if ($root) { $root } else { "NOT FOUND" }
    Write-Host "Cache root : $rootText"
    Write-Host "Workspace  : $WORK"
    if (-not $root) { return }
    $targets = Get-Targets $root
    Write-Host "Templates  : $($targets.Count) file(s)"
    $backup = Join-Path $root $BACKUP_NAME
    Write-Host "Backup     : $(if (Test-Path $backup) { 'created' } else { 'not created' })"
    if (Test-Path $WORK) {
        $diff = 0
        foreach ($rel in $targets) {
            $w = Join-Path $WORK $rel
            if (-not (Test-Path $w)) { continue }
            $h1 = (Get-FileHash -Path $w -Algorithm MD5).Hash
            $h2 = (Get-FileHash -Path (Join-Path $root $rel) -Algorithm MD5).Hash
            if ($h1 -ne $h2) { $diff++ }
        }
        Write-Host "Differences: $diff file(s) differ between workspace and cache"
    } else {
        Write-Host "Workspace  : not created (run extract first)"
    }
}

function Show-Help {
    Write-Host "WorkBuddy Prompt Tool (Windows)"
    Write-Host ""
    Write-Host "Usage: .\wb-prompt.ps1 <command>"
    Write-Host ""
    Write-Host "  extract   Copy active templates to the desktop workspace for editing"
    Write-Host "  apply     Inject workspace changes back into cache (auto backup on first run)"
    Write-Host "  restore   Restore the official original from backup"
    Write-Host "  status    Show cache, workspace and backup status"
    Write-Host ""
    Write-Host "Typical flow: extract -> edit desktop files -> apply -> restart and open a NEW conversation"
}

$cmd = if ($args.Count -gt 0) { $args[0] } else { "" }
switch ($cmd.ToLower()) {
    "extract" { Invoke-Extract }
    "apply"   { Invoke-Apply }
    "restore" { Invoke-Restore }
    "status"  { Invoke-Status }
    default   { Show-Help }
}
