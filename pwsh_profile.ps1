# Import Modules
$VIM_RUNNING = $false
if (Test-Path env:NVIM_LISTEN_ADDRESS -ErrorAction SilentlyContinue) {
    $VIM_RUNNING = $true
}

$FULL_FEATURE_ENABLED = -not (Test-Path env:PWSH_SLIM)

if ($FULL_FEATURE_ENABLED) {
    Import-Module PSReadLine
    Import-Module posh-git
    if ($IsWindows) {
        Import-Module Pscx
    }
}

if ($VIM_RUNNING) {
    if (-not (Get-Command "nvr" -ErrorAction SilentlyContinue)) {
        Write-Error "Install neovim-remote"
    }

    function Nvim-Open-Remote() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths,
            [Parameter(Position=0, Mandatory=$true)]
            [ValidateSet("Vertical", "Horizontal", "Tab", "Current")]
            [String]
            $Mode
        )

        if ($Mode -eq "Vertical") {
            nvr -O $Paths
        }
        elseif ($Mode -eq "Horizontal") {
            nvr -o $Paths
        }
        elseif ($Mode -eq "Tab") {
            nvr --remote-tab $Paths
        }
        elseif ($Mode -eq "Current") {
            nvr -l $Paths
        }
    }

    function Nvim-Open-Vertical() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths
        )

        Nvim-Open-Remote -Paths $Path -Mode Vertical
    }

    function Nvim-Open-Horizontal() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths
        )

        Nvim-Open-Remote -Paths $Paths -Mode Horizontal
    }

    function Nvim-Open-Tab() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths
        )

        Nvim-Open-Remote -Paths $Paths -Mode Tab
    }

    function Nvim-Open-Current() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths
        )

        Nvim-Open-Remote -Paths $Paths -Mode Current
    }

    Set-Alias -Name nvmh -Value Nvim-Open-Horizontal
    Set-Alias -Name nvmv -Value Nvim-Open-Vertical
    Set-Alias -Name nvmt -Value Nvim-Open-Tab
    Set-Alias -Name nvim -Value Nvim-Open-Current
}

# Functions
function export() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Name,
        [Parameter(Position=1)]
        [String[]]
        $Value
    )
    [System.Environment]::SetEnvironmentVariable($Name, $Value)
}

if ($FULL_FEATURE_ENABLED) {
    function Get-Current-Branch() {
        return &git rev-parse --abbrev-ref HEAD
    }
}

if ($FULL_FEATURE_ENABLED) {
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
}

if ($IsMacOS) {
    function Is-Dark-Mode() {
        $output = (~/.dotfiles/Is-Dark-Theme.osascript) | Out-String
        $output = $output.Trim()
        if ($output -eq "false") {
            return 0
        }
        elseif ($output -eq "true") {
            return 1
        }
        else {
            Write-Error "Cannot parse output: $output"
        }
    }

    if ($FULL_FEATURE_ENABLED) {
        function Enable-Dylib-Verbose() {
            export DYLD_PRINT_LIBRARIES=1
            export DYLD_PRINT_LIBRARIES_POST_LAUNCH=1
            export DYLD_PRINT_RPATHS=1
        }

        function Disable-Dylib-Verbose() {
            export DYLD_PRINT_LIBRARIES=0
            export DYLD_PRINT_LIBRARIES_POST_LAUNCH=0
            export DYLD_PRINT_RPATHS=0
        }
    }
}

if ((Get-Command "curl" -ErrorAction SilentlyContinue) -and $FULL_FEATURE_ENABLED) {
    function Get-Public-IP() {
        curl http://ipconfig.io/ip
    }
}

if ((Get-Command "ctags" -ErrorAction SilentlyContinue) -and $FULL_FEATURE_ENABLED) {
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

function Copy-Pwd() {
    if ($IsMacOS) {
        (pwd).Path | pbcopy
    }
    else {
        Set-Clipboard (pwd).Path
    }
}

if (Get-Command "fd" -ErrorAction SilentlyContinue) {
    Set-Alias find fd
}

if (Get-Command "exa" -ErrorAction SilentlyContinue) {
    Set-Alias ls exa
}

if (Get-Command "bat" -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

if (Get-Command "nvim" -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
}

if ($IsMacOS) {
    export EDITOR 'nvim'

    if ($FULL_FEATURE_ENABLED) {
        function Post-Notification($message, $title) {
            osascript -e "display notification \`"$message\`" with title \`"$title\`""
        }

        function cd-icloud() {
            cd "~/Library/Mobile Documents/com~apple~CloudDocs/"
        }

        function Enable-Dylib-Verbose() {
            export DYLD_PRINT_LIBRARIES 1
            export DYLD_PRINT_LIBRARIES_POST_LAUNCH 1
            export DYLD_PRINT_RPATHS 1
        }

        function Disable-Dylib-Verbose() {
            export DYLD_PRINT_LIBRARIES 0
            export DYLD_PRINT_LIBRARIES_POST_LAUNCH 0
            export DYLD_PRINT_RPATHS 0
        }

        Set-Alias lock-screen "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession -suspend"

        # Tmux launcher
        #
        # See:
        #     http://github.com/brandur/tmux-extra
        #
        # Modified version of a script orginally found at:
        #     http://forums.gentoo.org/viewtopic-t-836006-start-0.html
        # Taken from: https://github.com/brandur/tmux-extra/blob/master/tmx
        # and slightly modified.
        function Tmux-Run() {
            $base_session="main"
            $sessions = tmux ls
            $tmux_nb = ([regex]::Matches($sessions, "${base_session}:")).count
            if ($tmux_nb -eq 0) {
                Write-Host "Launching tmux base session ${base_session}..."
                tmux -u new-session -s $base_session
            }
            else {
                # Make sure we are not already in a tmux session
                if (!(Test-Path env:TMUX)) {
                    Write-Host "Launching copy of base session ${base_session}..."
                    # Use the number of windows in the group to name the new session.
                    # Explude the first main session from the count.
                    $sessions = tmux ls | rg -F -v 'main:'
                    $group_count = ([regex]::Matches($sessions, '(group main)')).count
                    $group_count = $group_count + 1
                    $session_id = "main-${group_count}"
                    # Create a new session (without attaching it) and link to base session
                    # to share windows
                    tmux new-session -d -t $base_session -s $session_id
                    # Attach to the new session
                    tmux -u attach-session -t $session_id
                    # When we detach from it, kill the session
                    tmux kill-session -t $session_id
                }
            }
        }

        function Tmux-Dump() {
            Param(
                [Parameter(Position=0, Mandatory=$true)]
                [String[]]
                $SessionPath
            )
            tmux list-windows -a -F "#S #W #{pane_current_path}" > $SessionPath
        }

        function Tmux-Add-Window() {
            Param(
                [Parameter(Position=0, Mandatory=$true)]
                [Int]
                $Index,
                [Parameter(Position=1, Mandatory=$true)]
                [String]
                $SessionName,
                [Parameter(Position=2, Mandatory=$true)]
                [String]
                $WindowName,
                [Parameter(Position=3, Mandatory=$true)]
                [String]
                $StartDirectory
            )

            tmux new-window -d -t $SessionName -n $WindowName -c $StartDirectory -t $Index
        }

        function Tmux-Add-Session() {
            Param(
                [Parameter(Position=0, Mandatory=$true)]
                [String[]]
                $SessionName,
                [Parameter(Position=1, Mandatory=$true)]
                [String[]]
                $WindowName,
                [Parameter(Position=2, Mandatory=$true)]
                [String[]]
                $StartDirectory
            )

            tmux new-session -d -s $SessionName -n $WindowName -c $StartDirectory
        }

        function Tmux-Has-Session() {
            Param(
                [Parameter(Position=0, Mandatory=$true)]
                [String[]]
                $SessionName
            )

            tmux has-session -t $SessionName
            if ($?) {
                return 1
            }

            return 0
        }

        function Tmux-Restore() {
            Param(
                [Parameter(Position=0, Mandatory=$true)]
                [String[]]
                $SessionPath
            )

            tmux start-server
            if (-not (Test-Path $SessionPath -ErrorAction SilentlyContinue)) {
                Write-Error "$SessionPath does not exist."
                return -1
            }

            $lines = Get-Content -Path $SessionPath
            for ($index = 0; $index -lt $lines.Length; $index++) {
                $line = $lines[$index]
                $parts = $line.Split(' ')

                $sessionName = $parts[0]
                $windowName = $parts[1]
                $startDirectory = $parts[2]
                $windowIndex = $index + 1
                if (Tmux-Has-Session $sessionName) {
                    Tmux-Add-Window $windowIndex $sessionName $windowName $startDirectory
                }
                else {
                    Tmux-Add-Session $sessionName $windowName $startDirectory
                }
            }
        }
    }
} # End MacOS

if ($IsWindows) {
    $Shell = $Host.UI.RawUI

    $size = $Shell.BufferSize
    $size.width=90
    try {
        $Shell.BufferSize = $size
    }
    catch {}

    $size = $Shell.WindowSize
    $size.width=90
    try {
        $Shell.WindowSize = $size
    }
    catch {}

    Set-Alias open explorer.exe
} # End Windows

function cd-desktop() {
    cd ~/Desktop
}

function cd-downloads() {
    cd ~/Downloads
}

if ($FULL_FEATURE_ENABLED) {
    # Returns the direct download link for a Google Drive share link.
    function gdocs2d($url) {
        $subs = "/d/"
        $index = $url.IndexOf($subs)
        if ($index -lt 0) {
            Write-Error "Cannot process the link."
            return
        }

        $url = $url.Substring(
            $index + $subs.length,
            $url.length - ($index + $subs.length)
        )
        $index = $url.IndexOf("/")
        if ($index -lt 0) {
            Write-Error "Cannot process the link."
            return
        }

        $fileID = $url.Substring(0, $index)
        $url = "https://drive.google.com/uc?export=download&id=$fileID"
        return $url
    }

    # Code from: https://stackoverflow.com/a/37275209
    Function Generate-Password() {
        Param(
            [Int]$Size = 12,
            [Char[]]$CharSets = "ULNS",
            [Char[]]$Exclude
        )

        $Chars = @()
        $TokenSet = @()
        If (!$TokenSets) {
            $Global:TokenSets = @{
                U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ' # Upper case
                L = [Char[]]'abcdefghijklmnopqrstuvwxyz' # Lower case
                N = [Char[]]'0123456789' # Numerals
                S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_{|}~' # Symbols
            }
        }

        $CharSets | ForEach {
            $Tokens = $TokenSets."$_" | ForEach {
                If ($Exclude -cNotContains $_) {
                    $_
                }
            }
            If ($Tokens) {
                $TokensSet += $Tokens
                # Character sets defined in upper case are mandatory
                If ($_ -cle [Char]"Z") {
                    $Chars += $Tokens | Get-Random
                }
            }
        }

        While ($Chars.Count -lt $Size) {
            $Chars += $TokensSet | Get-Random
        }

        # Mix the (mandatory) characters and output string
        ($Chars | Sort-Object {Get-Random}) -Join ""
    }
}

if ($FULL_FEATURE_ENABLED) {
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
}

# Git
function Load-Git-Config() {
    git config --global alias.st 'status'
    git config --global alias.stage 'add'
    git config --global alias.unstage 'reset HEAD --'

    git config --global alias.last 'log -1 HEAD'
    git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    git config --global alias.logpretty "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.tasks "!rg 'TODO|FIXME' ./"
    git config --global alias.discard 'checkout --'
    git config --global alias.code-changes "!git log --format=format: --name-only | egrep -v '^$' | sort | uniq -c | sort -rg | head -10"
}

function sitrep() {
    git status
}

function Git-Set-Author($name, $email) {
    git config user.name "$name"
    git config user.email "$email"
}

# Module Configurations
## Posh-Git Configuration
if ($FULL_FEATURE_ENABLED) {
    $GitPromptSettings.DefaultPromptWriteStatusFirst = $true
    $GitPromptSettings.EnableFileStatus = $false
    $GitPromptSettings.DefaultPromptBeforeSuffix.Text = ':`n'
    $GitPromptSettings.DefaultPromptSuffix = '$("=>" * ($nestedPromptLevel + 1)) '
}

## PSReadLine Options

if ($FULL_FEATURE_ENABLED) {
    $PSReadLineOptions = @{
        EditMode = "Vi"
        HistoryNoDuplicates = $true
        HistorySearchCursorMovesToEnd = $true
        HistorySaveStyle = "SaveIncrementally"
        ViModeIndicator = "Cursor"
        Colors = @{
            # cosmic-latte colors
            "Error" = "#202a31"
            "String" = "#7d9761"
            "Command" = "#8181f7"
            "Comment" = "#898f9e"
            "Operator" = "#459d90"
            "Number" = "#5496bd"
        }
    }

    Set-PSReadLineOption @PSReadLineOptions
}

if ((Test-Path env:VIRTUAL_ENV) -and (Test-Path "${env:VIRTUAL_ENV}/bin/activate.ps1")) {
    . ${env:VIRTUAL_ENV}/bin/activate.ps1
}
