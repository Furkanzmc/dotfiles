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
            [ValidateSet("c++", "python", "c")]
            [String]
            $Langauge="c++"
        )

        if ($Langauge -eq "c++") {
            ctags -R --fields=+l --languages=c++ .
        }
        elseif ($Langauge -eq "python") {
            ctags -R --fields=+l --languages=python --python-kinds=-iv .
        }
        elseif ($Langauge -eq "c") {
            ctags -R --fields=+l --languages=c++,c --python-kinds=-iv .
        }
        else {
            Write-Error "$Language is not supported."
        }
    }
}

function Get-Current-Branch() {
    return &git rev-parse --abbrev-ref HEAD
}

function Get-Weather() {
    (Invoke-WebRequest http://v2.wttr.in/).Content
}

function _Set-Alacritty-Color($Color) {
    if (-not (Test-Path ~/.dotfiles/terminals/alacritty.yml -ErrorAction SilentlyContinue)) {
        return
    }

    $content = Get-Content ~/.dotfiles/terminals/alacritty.yml
    if ($content -match "\*dark" -and $Color -eq "light") {
        $content = $content.Replace("*dark", "*light")
    }
    elseif ($content -match "\*light" -and $Color -eq "dark") {
        $content = $content.Replace("*light", "*dark")
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
        [Switch]$MatchTheme=$false
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

    if ($ChangeInAllNeovimInstances) {
        $nvimPath = "$HOME/.dotfiles/scripts/nvim.py"
        $command = "`"set background=$Color`""
        Start-Process -FilePath python3 -ArgumentList `
            $nvimPath,"--command ",$command -NoNewWindow
    }

    if ($Color -ne "") {
        $env:VIMRC_BACKGROUND = $Color
        $env:VIMRC_TERMINAL_THEME = $Color
        $env:FZF_DEFAULT_OPTS = "--bind='ctrl-l:toggle-preview' --color=$Color"
        _Set-Alacritty-Color $Color

        if ($Color -eq "light") {
            $env:BAT_THEME = "gruvbox-light"
        }
        else {
            $env:BAT_THEME = "gruvbox"
        }
    }

    if ($IsWindows -and (Test-Path env:PWSH_WINDOWS_TERMINAL_SETTINGS -ErrorAction SilentlyContinue)) {
        $content = Get-Content $env:PWSH_WINDOWS_TERMINAL_SETTINGS
        # Lazy way of doing this...
        $content = $content.Replace('"colorScheme": "dark"', '"colorScheme": "' + $Color + '"')
        $content = $content.Replace('"colorScheme": "light"', '"colorScheme": "' + $Color + '"')
        Set-Content -Path $env:PWSH_WINDOWS_TERMINAL_SETTINGS -Value $content
    }
}

function Define-Word($word) {
    curl dict://dict.org/d:"$word" | nvim --noplugin "+setlocal filetype=man"
}
Set-Alias -Name dict -Value Define-Word

# Sample usage: `git --help | nman`
function nman($Input) {
    $Input | nvim "+setlocal filetype=man"
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
        Push-Location build
        if ($IsWindows) {
            fd . -t f | rm -Force
        }
        else {
            fd . -t f | rm -rf
        }
        Pop-Location
    }
    else {
        mkdir build
    }

    if (Test-Path .deps -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Blue "Deleting the contents of the .deps directory."
        Push-Location .deps
        if ($IsWindows) {
            fd . -t f | rm -Force
        }
        else {
            fd . -t f | rm -rf
        }
        Pop-Location
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
        cmake -G "Visual Studio 16 2019" -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 ..\cmake.deps\
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
        cmake -G "Visual Studio 16 2019" -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 -DCMAKE_INSTALL_PREFIX="$InstallPath" ../
    }
    else {
        cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=1 -DCMAKE_INSTALL_PREFIX="$InstallPath" ../
    }

    if (-not $?) {
        Write-Host -ForegroundColor Red "Error while configuring the neovim."
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

    if ($Install -and $IsWindows) {
        Write-Host -ForegroundColor Blue "Installing neovim."
        cmake --build . --target install --config Release
    }
    elseif ($Install -and $IsMacOS) {
        Write-Host -ForegroundColor Blue "Installing neovim."
        ninja install
    }

    Pop-Location

    Write-Host -ForegroundColor Green "Build succeeded."

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
        osascript -e "display notification \`"$Message\`" with title \`"$Title\`""
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

if (Get-Command "ffmpeg" -ErrorAction SilentlyContinue) {
    function Create-Time-Lapse() {
        Param(
            [Parameter(Mandatory=$true)]
            [String]
            $SourceDir,
            [Parameter(Mandatory=$false)]
            [String]
            $FramesOutDir,
            [Parameter(Mandatory=$true)]
            [String]
            $OutDir,
            [Parameter(Mandatory=$true)]
            [String]
            $SourceExtension,
            [Parameter(Mandatory=$true)]
            [String]
            $OutExtension="mov"
        )

        $files = $(Get-ChildItem -Name -Filter *.$SourceExtension -Path $SourceDir)
        $files | ForEach-Object {
            Remove-Item -Path "$FramesOutDir/*"
            if ($_ -ne $Entry) {
                ffmpeg -i "$SourceDir/$_" -vf fps=2 "$FramesOutDir/%06d.png"
                if ($?) {
                    ffmpeg -framerate 10 -i "$FramesOutDir/%06d.png" "$OutDir/$_.$OutExtension"
                }
            }
        }
    }
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Utils in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
