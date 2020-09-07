function Get-Git-Status-Dict() {
    $status = $(git status --short --branch)
    if (! $?) {
        return
    }

    $stagedCount = $status | Select-String -Pattern "(^R|^M|^D)" | Measure-Object | Select-Object -ExpandProperty Count
    $modifiedCount = $status | Select-String -Pattern "(^MM|^ M)" | Measure-Object | Select-Object -ExpandProperty Count
    $renamedCount = $status | Select-String -Pattern "(^ R|^RR)" | Measure-Object | Select-Object -ExpandProperty Count
    $newCount = $status | Select-String -Pattern "(^\?\?|^ \?\?)" | Measure-Object | Select-Object -ExpandProperty Count
    $deletedCount = $status | Select-String -Pattern "(^DD|^ D)" | Measure-Object | Select-Object -ExpandProperty Count

    if ($status.GetType().Name -eq "Object[]") {
        $branchLine = $status[0]
    }
    else {
        $branchLine = $status
    }

    $result = $branchLine | Select-String -Pattern "behind [0-9]+"
    $behindCount = 0
    if ($result) {
        $currentMatch = $result.Matches[0]
        $behindCount = $currentMatch -replace "behind "
    }

    $result = $branchLine | Select-String -Pattern "ahead [0-9]+"
    $aheadCount = 0
    if ($result) {
        $currentMatch = $result.Matches[0]
        $aheadCount = $currentMatch -replace "ahead "
    }

    $output = "M$modifiedCount D$deletedCount ??$newCount ↑$aheadCount ↓$behindCount"
    return @{`
        "modified"=$modifiedCount; `
        "deleted"=$deletedCount; `
        "untracked"=$newCount; `
        "staged"=$stagedCount; `
        "ahead"=$aheadCount; `
        "behind"=$behindCount `
    }
}

function Cache-Git-Status() {
    $gitDir = &git rev-parse --git-dir
    $gitStatusFile = Join-Path -Path $gitDir -ChildPath status_prompt.json
    $lockFile = Join-Path -Path $gitDir -ChildPath index.lock
    if (Test-Path $lockFile -ErrorAction SilentlyContinue) {
        return
    }

    $status = Get-Git-Status-Dict
    $jsonContent = ConvertTo-Json $status
    Set-Content -Path $gitStatusFile -Value $jsonContent
}

function Write-Git-Prompt($date) {
    $gitDir = &git rev-parse --git-dir
    # Continue if the command succeeded.
    if (! $?) {
        return
    }

    $branchName = Get-Content ( `
        Join-Path $gitDir -ChildPath HEAD `
    )
    $branchName = $branchName.Replace("ref: ", "")
    $branchName = $branchName.Replace("refs/heads/", "")

    # Check for an active rebase.
    $rebaseMergePath = Join-Path $gitDir -ChildPath rebase-merge
    $rebasing = Test-Path -Path $rebaseMergePath
    if ($rebasing) {
        Write-Host " $branchName" -ForegroundColor Cyan -NoNewLine
        Write-Host ":" -ForegroundColor Green -NoNewLine
        $isInteractiveRebase = Test-Path -Path (`
                Join-Path $rebaseMergePath -ChildPath interactive `
                )
        if ($isInteractiveRebase) {
            Write-Host "REBASE-I" -ForegroundColor Blue -NoNewLine
        }
        else {
            Write-Host "REBASE-M" -ForegroundColor Blue -NoNewLine
        }
    }
    else {
        Write-Host " $branchName" -ForegroundColor Cyan -NoNewLine
    }

    if (Test-Path env:PWSH_GIT_PROMPT_DISABLED -ErrorAction SilentlyContinue) {
        Write-Host " " -NoNewLine
        return
    }

    $gitStatusFile = Join-Path -Path $gitDir -ChildPath status_prompt.json
    $envExists = Test-Path env:PWSH_PROMPT_CACHE_PROCESS_ID -ErrorAction SilentlyContinue
    if (-not $envExists -or ($envExists -and -not (Get-Process -Id $env:PWSH_PROMPT_CACHE_PROCESS_ID -ErrorAction SilentlyContinue))) {
        $process = Start-Process -FilePath pwsh -ArgumentList "-C Cache-Git-Status" `
            -NoNewWindow -PassThru -RedirectStandardOutput "~/.dotfiles/pwsh/tmp_dirs/out_null" `
            -RedirectStandardError  "~/.dotfiles/pwsh/tmp_dirs/out_null_err"
        $env:PWSH_PROMPT_CACHE_PROCESS_ID=$process.Id
    }

    if (! (Test-Path $gitStatusFile -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Cyan " (" -NoNewLine
        Write-Host -ForegroundColor DarkYellow "…" -NoNewLine
        Write-Host -ForegroundColor Cyan ") " -NoNewLine
    }
    else {
        $statusVars = Get-Content $gitStatusFile | ConvertFrom-Json
        $staged = $statusVars.staged
        $modified = $statusVars.modified
        $deleted = $statusVars.deleted
        $untracked = $statusVars.untracked
        $behind = $statusVars.behind
        $ahead = $statusVars.ahead

        if ($staged -eq 0 -and $modified -eq 0 -and $deleted -eq 0 -and $untracked `
            -eq 0 -and $behind -eq 0 -and $ahead -eq 0) {
            Write-Host -ForegroundColor Green " ✔ " -NoNewLine
            return
        }

        Write-Host -ForegroundColor Cyan " (" -NoNewLine
        if ($staged -gt 0) {
            Write-Host -ForegroundColor Blue "●$staged" -NoNewLine
        }

        if ($modified -gt 0) {
            Write-Host -ForegroundColor Blue "+$modified" -NoNewLine
        }

        if ($deleted -gt 0) {
            Write-Host -ForegroundColor Red "-$deleted" -NoNewLine
        }

        if ($untracked -gt 0) {
            Write-Host -ForegroundColor DarkYellow "?$untracked" -NoNewLine
        }

        if ($behind -gt 0) {
            Write-Host -ForegroundColor Red "↓$behind" -NoNewLine
        }

        if ($ahead -gt 0) {
            Write-Host -ForegroundColor Green "↑$ahead" -NoNewLine
        }

        Write-Host -ForegroundColor Cyan ") " -NoNewLine
    }
}

function Write-Prompt() {
    $lastCommandSucceeded = $?
    $exitCode = $LastExitCode
    if (Test-Path env:VIRTUAL_ENV -ErrorAction SilentlyContinue) {
        Write-Host "(.venv) " -ForegroundColor Yellow -NoNewLine
    }

    $currentLocation = $(Get-Location).Path
    if ($IsMacOS) {
        $currentLocation = $currentLocation.Replace($env:HOME, "~")
    }
    else {
        $currentLocation = $currentLocation.Replace($env:USERPROFILE, "~")
    }
    $maxWidth = 80

    if ($currentLocation.Length -gt $maxWidth) {
        $p1 = $currentLocation.Substring(0, $currentLocation.IndexOf("/", 2) + 1)
        $lastSlash = $currentLocation.IndexOf("/", $maxWidth + $p1.Length)
        $currentLocation = $p1 + "..." + $currentLocation.Substring($lastSlash)
    }

    Write-Host "$currentLocation " -NoNewLine -ForegroundColor Blue

    $date = Get-Date
    Write-Git-Prompt $date

    Write-Host $(Get-Date -Format "[HH:mm:ss]") `
        -ForegroundColor DarkYellow -NoNewLine

    if ($lastCommandSucceeded -eq $false) {
        $bufferSize = (Get-Host).UI.RawUI.BufferSize.Width
        Write-Host " ! $exitCode" -NoNewLine -ForegroundColor Red
    }

    if ($lastCommandSucceeded) {
        Write-Host "`n$("=>" * ($NestedPromptLevel + 1))" -NoNewLine -ForegroundColor Green
    }
    else {
        Write-Host "`n$("=>" * ($NestedPromptLevel + 1))" -NoNewLine -ForegroundColor Red
    }

    $themeFile = "~/.dotfiles/pwsh/tmp_dirs/system_theme"
    if (Test-Path $themeFile -ErrorAction SilentlyContinue) {
        $content = Get-Content $themeFile
        if ($content -match "dark") {
            Set-Terminal-Theme dark | Out-Null
        }
        else {
            Set-Terminal-Theme light | Out-Null
        }
    }
}

Export-ModuleMember -Function Write-Prompt
Export-ModuleMember -Function Cache-Git-Status
