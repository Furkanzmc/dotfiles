if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

function Virtualenv-Activate() {
    if (Test-Path "./.venv/bin/activate.ps1" -ErrorAction SilentlyContinue) {
        . ./.venv/bin/activate.ps1
    }
    else {
        Write-Warning "No virtualenv is found."
    }
}

if (Get-Command "fzf" -ErrorAction SilentlyContinue) {
    function Fzf-List-Process() {
        $color = $env:VIMRC_BACKGROUND -eq "light" ? "light" : "dark"
        $command = 'Get-Process | Where-Object { `
            $_.ProcessName.Length -gt 0 `
        } | Format-Table Id,ProcessName,StartTime'
        $killCommand = '$processId = Select-String -Pattern "^[0-9]+" -InputObject {} `
                    | Select-Object -ExpandProperty Matches `
                    | Select-Object -Index 0 | Select-Object -ExpandProperty Value;`
                    Stop-Process $processId'

        Get-Process | Where-Object {`
            $_.ProcessName.Length -gt 0 `
        } | Format-Table Id,ProcessName,StartTime `
          | fzf --reverse --no-mouse --color=$color `
            --header 'Press <C-q> to kill the process, <C-r> to refresh the list.' `
            --bind 'ctrl-d:page-down' `
            --bind 'ctrl-u:page-up' `
            --bind "ctrl-q:execute-silent($killCommand)+kill-line+clear-query+reload($command)" `
            --bind "ctrl-r:reload($command)"
    }

    function Fzf-History() {
        Param(
            [Parameter(Position=0, Mandatory=$false)]
            [Switch]
            $All=$false
        )

        $count = 1000
        if ($All) {
            $count = -1
        }

        $selectedItem = Get-Content (Get-PSReadlineOption).HistorySavePath `
            -Tail $count | `
            fzf --header `
                "Press Enter to copy the line, <C-r> to list all history, <C-l> to only list the last 1000." `
                --reverse --tac `
                --bind "ctrl-r:reload(Get-Content (Get-PSReadlineOption).HistorySavePath)" `
                --bind "ctrl-l:reload(Get-Content (Get-PSReadlineOption).HistorySavePath -Tail 1000)"
        Write-Host $selectedItem -ForegroundColor blue
        Set-Clipboard $selectedItem
    }

    function Add-Dir-Bookmark() {
        $location = Get-Location
        Add-Content -Path "$HOME/.dotfiles/pwsh/tmp_dirs/bookmarks.txt" `
            -Value $location.Path
    }

    function Remove-Dir-Bookmark() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String]
            $Entry
        )

        $bookmarkPath = "$HOME/.dotfiles/pwsh/tmp_dirs/bookmarks.txt"
        $content = Get-Content -Path $bookmarkPath
        $newContent = [System.Collections.ArrayList]@()

        Set-Content -Path $bookmarkPath -Value ""
        $content | ForEach-Object {
            if ($_ -ne $Entry) {
                Add-Content -Path $bookmarkPath -Value $_
            }
        }
    }

    function Get-Dir-Bookmarks() {
        $bookmarkPath = "$HOME/.dotfiles/pwsh/tmp_dirs/bookmarks.txt"
        $refreshCommand = 'Get-Content ' + $bookmarkPath + ' | Sort-Object -Unique | Where-Object { $_.Length -gt 0 }'
        if (Test-Path $bookmarkPath -ErrorAction SilentlyContinue) {
            Get-Content $bookmarkPath | Sort-Object -Unique `
                | Where-Object { $_.Length -gt 0 } `
                | fzf --reverse +x --header "Press enter to navigate, <C-r> to remove the selected bookmark." `
                --bind "ctrl-r:execute-silent(Remove-Dir-Bookmark {})+reload($refreshCommand)" `
                | Where-Object { Test-Path $_ -ErrorAction SilentlyContinue} | Set-Location
        }
        else {
            Write-Host "No bookmarks file."
        }
    }

    function Get-Commands() {
        $selected = Get-Command -All | Select-Object -Property CommandType,Name `
            | fzf --reverse +x --header "Press enter to copy the command."
        if ($selected) {
            $selected = $selected.Trim().Split(" ")[1]
            Write-Host $selected -ForegroundColor blue
            Set-Clipboard $selected
        }
    }

    Set-Alias -Name hs -Value Fzf-History
    Set-Alias -Name mm -Value Add-Dir-Bookmark
    Set-Alias -Name ms -Value Get-Dir-Bookmarks

    Set-Alias -Name commands -Value Get-Commands
    Set-Alias -Name ps -Value Fzf-List-Process
}

function Copy-Pwd() {
    if ($IsMacOS) {
        (pwd).Path | pbcopy
    }
    else {
        Set-Clipboard (pwd).Path
    }
}

function Encode-Base64() {
    Param(
        [String]$Text
    )

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
    return [Convert]::ToBase64String($bytes)
}

function Decode-Base64() {
    Param(
        [String]$Base64Text
    )

    $bytes = [Convert]::FromBase64String($Base64Text)
    return [BitConverter]::ToString($bytes)
}

if (Get-Command "ctags" -ErrorAction SilentlyContinue) {
    function Generate-Tags() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [ValidateSet("c++", "python")]
            [String]
            $Langauge="c++"
        )

        if ($Langauge -eq "c++") {
            ctags -R --c++-kinds=+p --exclude=build --fields=+iaS --extra=+q .
        }
        elseif ($Langauge -eq "python") {
            ctags -R --python-kinds=-i --exclude=build --fields=+iaS --extra=+q .
        }
        else {
            Write-Error "$Language is not supported."
        }
    }
}

function Get-Current-Branch() {
    return &git rev-parse --abbrev-ref HEAD
}

function Replace-In-Dir($from, $to) {
    if (Get-Command "rg" -ErrorAction SilentlyContinue) {
        if ($IsMacOS) {
            rg -l -F "$from" | xargs sed -i -e "s/$from/$to/g"
        }
        else {
            Write-Host 'replace_in_dir is not supported on this platform.'
        }
    }
    else {
        Write-Host "rg is not found."
    }
}

function Get-Weather() {
    (Invoke-WebRequest http://v2.wttr.in/).Content
}

function Switch-Terminal-Theme() {
    $content = Get-Content ~/.dotfiles/terminals/alacritty.yml
    if ($content -match "\*dark") {
        $content = $content.Replace("*dark", "*light")
        $command = '"set background=light"'
    }
    else {
        $content = $content.Replace("*light", "*dark")
        $command = '"set background=dark"'
    }

    if ($IsMacOS) {
        $nvimPath = "$HOME/.dotfiles/scripts/nvim.py"
    }
    else {
        $nvimPath = "$USERHOME/.dotfiles/scripts/nvim.py"
    }

    Set-Content -Path ~/.dotfiles/terminals/alacritty.yml -Value $content
    Start-Process -FilePath python3 -ArgumentList `
        $nvimPath,"--command ",$command -NoNewWindow
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Utils in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
