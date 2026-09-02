# check-commit.ps1
# Pre-commit checklist for the aicode superproject.
# Run from the aicode root:
#   powershell -ExecutionPolicy Bypass -File .\check-commit.ps1

$ErrorActionPreference = "Continue"

# result collector
$checks = @()
function Add-Check($name, $ok, $detail) {
    $script:checks += [PSCustomObject]@{
        Name   = $name
        Status = if ($ok) { "PASS" } else { "FAIL" }
        Detail = $detail
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " aicode pre-commit checklist" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ---------- 0. environment ----------
$root = (Get-Location).Path
if (-not (Test-Path (Join-Path $root ".gitmodules"))) {
    Add-Check "location" $false "Not the aicode superproject root (no .gitmodules). Run in the cloned aicode root directory"
    $checks | Format-Table -AutoSize
    exit 1
}
Add-Check "location" $true $root

# ---------- submodule list (needed by later checks) ----------
$submodules = @(git config --file .gitmodules --get-regexp "submodule\..*\.path" | ForEach-Object { ($_ -split " ", 2)[1] })
if ($submodules.Count -eq 0) {
    Add-Check "submodules" $false "No submodules parsed from .gitmodules"
}

# ---------- 1. superproject working tree (excluding submodule pointers) ----------
$allPorcelain = @(git -c core.quotepath=false status --porcelain)
$changed = @($allPorcelain | Where-Object {
    $p = $_.Substring(3)
    $submodules -notcontains $p
})
$pointerLines = @($allPorcelain | Where-Object {
    $p = $_.Substring(3)
    $submodules -contains $p
})
if ($changed.Count -eq 0) {
    Add-Check "superproject worktree" $true "clean"
} else {
    Add-Check "superproject worktree" $false ("Uncommitted changes: " + $changed.Count + " item(s). git add + commit first.")
}

# ---------- 2. submodules ----------
if ($submodules.Count -gt 0) {
    foreach ($sub in $submodules) {
        $subPath = Join-Path $root $sub
        if (-not (Test-Path $subPath)) {
            Add-Check "submodule $sub" $false "Missing directory. Run: git submodule update --init --recursive"
            continue
        }
        Push-Location $subPath
        $dirty = @(git status --porcelain)
        $branchLine = git status -sb | Select-Object -First 1
        $isAhead  = $branchLine -match "ahead"
        $isBehind = $branchLine -match "behind"
        $diverged = $isAhead -and $isBehind
        if ($dirty.Count -gt 0) {
            Add-Check "submodule $sub" $false ("Dirty worktree: " + $dirty.Count + " uncommitted item(s). Commit inside the submodule first.")
        } elseif ($diverged) {
            Add-Check "submodule $sub" $false "Diverged (ahead AND behind). Run: git pull --rebase"
        } elseif ($isAhead) {
            Add-Check "submodule $sub" $false "Local commits not pushed. Run: git push"
        } elseif ($isBehind) {
            Add-Check "submodule $sub" $false "Behind remote. Run: git pull --rebase"
        } else {
            Add-Check "submodule $sub" $true "synced with origin, worktree clean"
        }
        Pop-Location
    }
}

# ---------- 3. superproject submodule pointers ----------
if ($pointerLines.Count -eq 0) {
    Add-Check "submodule pointers" $true "in sync"
} else {
    Add-Check "submodule pointers" $false ("Pointer changes pending. git add the submodule path(s) and commit.")
    foreach ($line in $pointerLines) {
        Write-Host ("      " + $line) -ForegroundColor Yellow
    }
}

# ---------- 4. sensitive files (superproject + every submodule) ----------
# Note 1: the superproject's ls-files only lists submodule paths as gitlink entries,
#         so files tracked INSIDE a submodule must be checked in that submodule itself.
# Note 2: patterns use wildcard substring matching. Bare words like "gds_token" would
#         never match a real path (e.g. mall/common/gds_token.json), so every pattern
#         must carry wildcards. Keyword patterns (password/secret) are limited to data
#         file extensions to avoid false positives on source code such as
#         SDK_ReleaseforAndroid's GridPasswordView sample classes.
$sensitivePatterns = @(
    "*gds_token*",
    "*.env", "*.env.*",
    "*.key", "*.pem", "*.p12", "*.pfx",
    "id_rsa*", "*credential*",
    "*password*.json", "*password*.txt", "*password*.yml", "*password*.yaml",
    "*secret*.json", "*secret*.txt", "*secret*.yml", "*secret*.yaml"
)

$reposToScan = New-Object System.Collections.Generic.List[object]
$reposToScan.Add(@{ Path = $root; Label = "aicode" })
foreach ($sub in $submodules) {
    $reposToScan.Add(@{ Path = (Join-Path $root $sub); Label = $sub })
}

$sensitiveFound = New-Object System.Collections.Generic.List[string]
foreach ($repo in $reposToScan) {
    if (-not (Test-Path $repo.Path)) { continue }
    Push-Location $repo.Path
    foreach ($f in @(git -c core.quotepath=false ls-files)) {
        foreach ($p in $sensitivePatterns) {
            if ($f -like $p) {
                $sensitiveFound.Add($repo.Label + "/" + $f)
                break
            }
        }
    }
    Pop-Location
}

if ($sensitiveFound.Count -eq 0) {
    Add-Check "sensitive files" $true "none tracked (superproject + all submodules)"
} else {
    # file names are inlined into Detail so they stay visible even when the
    # host stream is redirected/piped (Write-Host alone can get swallowed)
    $shown = @($sensitiveFound | Select-Object -First 3)
    $detail = $sensitiveFound.Count.ToString() + " sensitive file(s) tracked: " + ($shown -join " | ")
    if ($sensitiveFound.Count -gt 3) { $detail += " | ..." }
    Add-Check "sensitive files" $false $detail
    foreach ($f in $sensitiveFound) {
        Write-Host ("      " + $f) -ForegroundColor Yellow
    }
}

# ---------- summary ----------
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
$checks | Format-Table -AutoSize
$failCount = @($checks | Where-Object { $_.Status -eq "FAIL" }).Count
$passCount = @($checks | Where-Object { $_.Status -eq "PASS" }).Count

if ($failCount -eq 0) {
    Write-Host ("ALL PASS (" + $passCount + "/" + $checks.Count + "). You may commit.") -ForegroundColor Green
    Write-Host "  Message format: <type>: <description>" -ForegroundColor DarkGray
    Write-Host "  type: feat | fix | chore | docs | refactor | style | test" -ForegroundColor DarkGray
    exit 0
} else {
    Write-Host ("FAILED: " + $failCount + " item(s). Fix them before committing!") -ForegroundColor Red
    exit 1
}
