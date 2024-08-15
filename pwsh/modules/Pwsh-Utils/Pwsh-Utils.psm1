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

function pvim() {
    Param(
        [Parameter(Mandatory=$false)]
        [Switch]
        $Neovide
    )
    $sessionFile = ""
    $rcFile = ""
    if (Test-Path session.vim -ErrorAction SilentlyContinue) {
        $sessionFile = "session.vim"
    }
    elseif (Test-Path session.nvim -ErrorAction SilentlyContinue) {
        $sessionFile = "session.nvim"
    }

    if (Test-Path .nvimrc -ErrorAction SilentlyContinue) {
        $rcFile = ".nvimrc"
    }
    elseif (Test-Path .nvim.lua -ErrorAction SilentlyContinue) {
        $rcFile = ".nvim.lua"
    }

    $arguments = ""
    if ($sessionFile -ne "" -and $rcFile -ne "") {
        if ($Neovide) {
            Start-Process -FilePath neovide -ArgumentList "--no-tabs -- -S $rcFile -S $sessionFile" -Environment @{AW_AUTO_SESSION=1}
        }
        else {
            nvim -S $rcFile -S $sessionFile '+let $AW_AUTO_SESSION=1'
        }
    }
    elseif ($sessionFile -ne "") {
        if ($Neovide) {
            Start-Process -FilePath neovide -ArgumentList "--no-tabs -- -S $sessionFile" -Environment @{AW_AUTO_SESSION=1}
        }
        else {
            nvim -S $sessionFile '+let $AW_AUTO_SESSION=1'
        }
    }
    elseif ($rcFile -ne "") {
        if ($Neovide) {
            Start-Process -FilePath neovide -ArgumentList "--no-tabs -- -S $rcFile" -Environment @{AW_AUTO_SESSION=1}
        }
        else {
            nvim -S $rcFile '+let $AW_AUTO_SESSION=1'
        }
    }
    else {
        if ($Neovide) {
            Start-Process -FilePath neovide -ArgumentList "--no-tabs" -Environment @{AW_AUTO_SESSION=1}
        }
        else {
            nvim '+let $AW_AUTO_SESSION=1'
        }
    }
}

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

function List-PRs() {
    Param(
        [Parameter(Mandatory=$false)]
        [String]
        $Reviewer="@me",
        [Parameter(Mandatory=$false)]
        [Switch]
        $Review
    )
    $color = $env:VIMRC_BACKGROUND -eq "light" ? "light" : "dark"
    $command = 'gh pr list --search "is:open is:pr review-requested:' + "$Reviewer"
    $reviewCommand = '$processId = Select-String -Pattern "^[0-9]+" -InputObject {} `
                ; git pr diff $processId > tmp.patch ; git apply tmp.patch | rm tmp.patch'

    $message = 'Press <C-r> to refresh the list'
    if ($Review) {
        $message += ", <enter> to review the PR locally."
    }
    $selection = gh pr list --search "is:open is:pr review-requested:$Reviewer" `
        | fzf --reverse --no-mouse --color=$color `
            --header $message `
            --bind 'ctrl-d:page-down' `
            --bind 'ctrl-u:page-up' `
            --bind "ctrl-r:reload($command)"
    if ($Review) {
        $prMatches = $(Select-String -Pattern "^[0-9]+" -InputObject $selection).Matches
        if ($prMatches.Length -ge 1) {
            gh pr diff $prMatches[0].Value > tmp.patch
            git apply tmp.patch
            $applySuccess = $?
            rm tmp.patch
            if ($applySuccess) {
                git add .
            }
        }
    }
}

function Fzf-History() {
    Param(
        [Parameter(Position=0, Mandatory=$false)]
        [Switch]
        $All=$false
    )

    if ($All) {
        $count = 1000
        $selectedItem = Get-Content (Get-PSReadlineOption).HistorySavePath `
            -Tail $count | `
            fzf --header `
            "Press Enter to copy the line, <C-r> to list all history, <C-l> to only list the last 1000." `
            --reverse --tac `
            --bind "ctrl-r:reload(Get-Content (Get-PSReadlineOption).HistorySavePath)" `
            --bind "ctrl-l:reload(Get-Content (Get-PSReadlineOption).HistorySavePath -Tail 1000)"
    }
    else {
        $selectedItem = Get-Content (Get-PSReadlineOption).HistorySavePath | `
            fzf --header `
            "Press Enter to copy the line, <C-r> to list all history, <C-l> to only list the last 1000." `
            --reverse --tac `
            --bind "ctrl-r:reload(Get-Content (Get-PSReadlineOption).HistorySavePath)" `
            --bind "ctrl-l:reload(Get-Content (Get-PSReadlineOption).HistorySavePath -Tail 1000)"
    }

    Write-Host $selectedItem -ForegroundColor blue
    Set-Clipboard $selectedItem
}

Set-Alias -Name hs -Value Fzf-History
Set-Alias -Name ps -Value Fzf-List-Process

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

function Generate-Tags() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateSet("c++", "python", "c")]
        [String]
        $Langauge="c++"
    )

    if ($Langauge -eq "c++") {
        ctags --exclude build* --exclude install* -R --fields=+l --languages=c++ .
    }
    elseif ($Langauge -eq "python") {
        ctags --exclude build/* -R --fields=+l --languages=python --python-kinds=-iv .
    }
    elseif ($Langauge -eq "c") {
        ctags --exclude build* --exclude install* -R --fields=+l --languages=c++,c --python-kinds=-iv .
    }
    else {
        Write-Error "$Language is not supported."
    }
}

function _Set-Alacritty-Color($Color) {
    $configFile = "~/.dotfiles/terminals/alacritty.yml"
    if (-not (Test-Path $configFile -ErrorAction SilentlyContinue)) {
        return
    }

    $content = Get-Content $configFile
    if ($content -match "alacritty_catppuccin_dark.toml" -and $Color -eq "light") {
        $content = $content.Replace("alacritty_catppuccin_dark.toml", "alacritty_catppuccin_light.toml")
    }
    elseif ($content -match "alacritty_catppuccin_light.toml" -and $Color -eq "dark") {
        $content = $content.Replace("alacritty_catppuccin_light.toml", "alacritty_catppuccin_dark.toml")
    }
    else {
        return
    }

    Set-Content -Path ~/.dotfiles/terminals/alacritty.yml -Value $content
}

function Set-Terminal-Theme() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateSet("light", "dark")]
        [String]$Color="",
        [Parameter(Mandatory=$false)]
        [Switch]$ChangeInAllNeovimInstances=$true,
        [Parameter(Mandatory=$false)]
        [Switch]$MatchTheme=$false,
        [Parameter(Mandatory=$false)]
        [Switch]$EnvOnly=$false
     )

    if ($MatchTheme) {
        if (Get-Command -Name Is-Dark-Mode -ErrorAction SilentlyContinue) {
            $IsDarkMode = Is-Dark-Mode
            if ($IsDarkMode) {
                $Color = "dark"
            }
            else {
                $Color = "light"
            }
        }
        else {
            Write-Error "Is-Dark-Mode script does not exist. Please see "
                        "github/furkanzmc/dotfiles for the function."
        }
    }

    if ($ChangeInAllNeovimInstances -and !($EnvOnly)) {
        $nvimPath = "$HOME/.dotfiles/scripts/nvim.py"
        $command = "`"set background=$Color`""
        Start-Process -FilePath python3 -ArgumentList `
            $nvimPath,"--command ",$command -NoNewWindow | Out-Null
    }

    if ($Color -ne "") {
        $env:VIMRC_BACKGROUND = $Color
        $env:VIMRC_TERMINAL_THEME = $Color
        $env:FZF_DEFAULT_OPTS = "--bind='ctrl-l:toggle-preview' --color=$Color"
        _Set-Alacritty-Color $Color

        if ($Color -eq "light") {
            $env:BAT_THEME = "OneHalfLight"
        }
        else {
            $env:BAT_THEME = "OneHalfDark"
        }

        if ($Color -eq "dark") {
            Set-PSReadLineOption -Colors @{
                "Error" = "#202a31"
                "String" = "#7d9761"
                "Comment" = "#898f9e"
                "InlinePrediction" = "#725658"
                "Command" = "#8181f7"
                "Number" = "#5496bd"
                "Member" = "DarkGray"
                "Operator" = "#459d90"
                "Type" = "DarkGray"
                "Variable" = "DarkGreen"
                "Parameter" = "DarkGreen"
                "ContinuationPrompt" = "DarkGray"
                "Default" = "DarkGray"
            }
        }
        else {
            Set-PSReadLineOption -Colors @{
                "Error" = "#202a31"
                "String" = "#7d9761"
                "Comment" = "#898f9e"
                "InlinePrediction" = "#e2aab0"
                "Command" = "#8181f7"
                "Number" = "#5496bd"
                "Member" = "DarkGray"
                "Operator" = "#459d90"
                "Type" = "DarkGray"
                "Variable" = "DarkGreen"
                "Parameter" = "DarkGreen"
                "ContinuationPrompt" = "DarkGray"
                "Default" = "DarkGray"
            }
        }
    }

    if ($IsWindows -and (Test-Path env:PWSH_WINDOWS_TERMINAL_SETTINGS -ErrorAction SilentlyContinue) -and !($EnvOnly)) {
        $content = Get-Content $env:PWSH_WINDOWS_TERMINAL_SETTINGS
        # Lazy way of doing this...
        $content = $content.Replace('"colorScheme": "dark"', '"colorScheme": "' + $Color + '"')
        $content = $content.Replace('"colorScheme": "light"', '"colorScheme": "' + $Color + '"')
        Set-Content -Path $env:PWSH_WINDOWS_TERMINAL_SETTINGS -Value $content
    }
}

function Build-Neovim() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]$SourcePath,
        [Parameter(Mandatory=$true)]
        [String]$InstallPath,
        [Parameter(Mandatory=$true)]
        [Switch]$Install
     )

    if (-not (Test-Path $SourcePath -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Red "$SourcePath does not exist."
        return 1
    }

    Push-Location $SourcePath

    Write-Host -ForegroundColor Blue "Using $SourcePath as source directory."

    if (Test-Path build -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Blue "Deleting the contents of the build directory."
        if ($IsWindows) {
            rm -Force -Recurse -Confirm:$false build/*
        }
        else {
            rm -rf build/*
        }
    }
    else {
        mkdir build
    }

    if (Test-Path .deps -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Blue "Deleting the contents of the .deps directory."
        if ($IsWindows) {
            rm -Force -Recurse -Confirm:$false .deps/*
        }
        else {
            rm -rf .deps/*
        }
    }
    else {
        mkdir .deps
    }

    if ($IsWindows) {
        Import-VisualStudioVars -Architecture x64
    }

    Write-Host -ForegroundColor Green "Changing directory to .deps"

    Push-Location .deps
    Write-Host -ForegroundColor Blue "Configuring the third party dependancies."

    if ($IsWindows) {
        cmake -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 ..\cmake.deps\
    }
    else {
        cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 ..\cmake.deps\
    }

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while configuring the dependancies."
        return 1
    }

    Write-Host -ForegroundColor Blue "Building the third party dependancies."

    if ($IsWindows) {
        cmake --build . --config Release
    }
    else {
        ninja -j12
    }

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while building the dependancies."
        return 1
    }
    Pop-Location

    Write-Host -ForegroundColor Green "Changing directory to build"

    Push-Location build
    Write-Host -ForegroundColor Blue "Configuring neovim."

    if ($IsWindows) {
        cmake -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 -DCMAKE_INSTALL_PREFIX="$InstallPath" ../
    }
    else {
        cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 -DCMAKE_INSTALL_PREFIX="$InstallPath" ../
    }

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while configuring neovim."
        return 1
    }

    Write-Host -ForegroundColor Blue "Building neovim."

    if ($IsWindows) {
        cmake --build . --config Release
    }
    else {
        ninja -j12
    }

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while building neovim."
        return 1
    }

    Write-Host -ForegroundColor Blue "Installing neovim."
    if ($Install -and $IsWindows) {
        cmake --build . --target install --config Release
    }
    elseif ($Install -and $IsMacOS) {
        ninja install
    }

    Pop-Location

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while installing neovim."
        return 1
    }
    else {
        Write-Host -ForegroundColor Green "Build succeeded."
    }

    Pop-Location
}

function Install-Lua-Lang-Server() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]$TargetPath
     )

    git clone https://github.com/sumneko/lua-language-server $TargetPath

    $repoDir = Join-Path -Path $TargetPath -ChildPath lua-language-server

    Push-Location $repoDir

    git submodule update --init --recursive

    if ($IsWindows) {
        Push-Location 3rd\luamake
        compile\install.bat
        Pop-Location

        3rd\luamake\luamake.exe rebuild
    }
    else {
        Push-Location 3rd/luamake
        compile/install.sh
        Pop-Location

        ./3rd/luamake/luamake rebuild
    }

    Pop-Location
}

function Post-Notification() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Title,
        [Parameter(Position=1, Mandatory=$false)]
        [String]
        $Message
    )

    if ($IsMacOS) {
        $command = "display notification" + '"' + $Message + '"' + " with title " + '"' + $Title + '"'
        osascript -e $command
    }
    else {
        Add-Type -AssemblyName System.Windows.Forms

        $balloon = New-Object System.Windows.Forms.NotifyIcon
        $path = (Get-Process -id $pid).Path
        $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $balloon.BalloonTipText = "$Message"
        $balloon.BalloonTipTitle = "$Title"
        $balloon.Visible = $true
        $balloon.ShowBalloonTip(1000)
    }
}

function Pwsh-Check-Health() {
    Write-Host "Checking for required binaries..." -ForegroundColor Blue

    if (-not (Get-Command "fd" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find fd..." -ForegroundColor Red
    }

    if (-not (Get-Command "nvim" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find nvim..." -ForegroundColor Red
    }

    if (-not (Get-Command "wc" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find wc..." -ForegroundColor Red
    }

    if (-not (Get-Command "Source-Env" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find Source-Env..." -ForegroundColor Red
    }

    if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find fzf..." -ForegroundColor Red
    }

    if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
        Write-Host "  - Cannot find ffmpeg..." -ForegroundColor Red
    }

    if ($IsMacOS) {
        if (-not (Get-Command "eza" -ErrorAction SilentlyContinue)) {
            Write-Host "  - Cannot find eza..." -ForegroundColor Red
        }

        if (-not (Get-Command "bat" -ErrorAction SilentlyContinue)) {
            Write-Host "  - Cannot find bat..." -ForegroundColor Red
        }

        if (-not (Get-Command "rmtrash" -ErrorAction SilentlyContinue)) {
            Write-Host "  - Cannot find rmtrash..." -ForegroundColor Red
        }
    }
}

function Diff-Branches() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Branch,
        [Parameter(Mandatory=$false)]
        [String]
        $Target="",
        [Parameter(Mandatory=$false)]
        [Switch]
        $Neovide
    )

    $nvimrcExists = $false
    $arguments = ""
    if (Test-Path .nvimrc -ErrorAction SilentlyContinue) {
        $nvimrcExists = $true
        $arguments = '+source .nvimrc | '
    }
    else {
        $arguments = '+'
    }

	if ($Target -ne "") {
        $arguments += "nmap <leader>d :lua require('vimrc').gdiffsplit('$Branch', '$Target')<CR>"
        $files = $(git diff $Branch $Target --name-only)
        $hash = $(git rev-parse $Branch)
        $git_path = $(git rev-parse --git-path /$hash)
        $branch_files = $(git diff --name-only $Branch $Target | ForEach-Object { "fugitive:///$git_path/$_"})
        if ($Neovide) {
            neovide --no-tabs $branch_files -- $arguments
        }
        else {
            nvim $arguments -- $branch_files
        }
	}
    else {
        $arguments += "nmap <leader>d :Gdiffsplit! $Branch<CR>"
        if ($Neovide) {
            neovide --no-tabs $(git diff $Branch --name-only) -- $arguments
        }
        else {
            nvim $arguments -- $(git diff $Branch --name-only)
        }
    }
}

function Diff-PR() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $PR
    )

    $TempFile = New-TemporaryFile
    gh pr diff $PR > $TempFile && git apply $TempFile && git add .
}

function Convert-Video-to-Gif() {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Input,
        [Parameter(Mandatory=$true)]
        [String]
        $Output
    )

    ffmpeg -i $Input -vf "fps=10,scale=1080:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 $Output
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Utils in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
