if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

$env:EDITOR = 'nvim'

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

function Enable-Dylib-Verbose() {
    $env:DYLD_PRINT_LIBRARIES=1
    $env:DYLD_PRINT_LIBRARIES_POST_LAUNCH=1
    $env:DYLD_PRINT_RPATHS=1
}

function Disable-Dylib-Verbose() {
    $env:DYLD_PRINT_LIBRARIES=0
    $env:DYLD_PRINT_LIBRARIES_POST_LAUNCH=0
    $env:DYLD_PRINT_RPATHS=0
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

    osascript -e "display notification \`"$Message\`" with title \`"$Title\`""
}

function Cd-iCloud() {
    cd "~/Library/Mobile Documents/com~apple~CloudDocs/"
}

function Enable-Dylib-Verbose() {
    $env:DYLD_PRINT_LIBRARIES = 1
    $env:DYLD_PRINT_LIBRARIES_POST_LAUNCH = 1
    $env:DYLD_PRINT_RPATHS = 1
}

function Disable-Dylib-Verbose() {
    $env:DYLD_PRINT_LIBRARIES = 0
    $env:DYLD_PRINT_LIBRARIES_POST_LAUNCH = 0
    $env:DYLD_PRINT_RPATHS = 0
}

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
        [String]
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
        [String]
        $SessionName,
        [Parameter(Position=1, Mandatory=$true)]
        [String]
        $WindowName,
        [Parameter(Position=2, Mandatory=$true)]
        [String]
        $StartDirectory
    )

    tmux new-session -d -s $SessionName -n $WindowName -c $StartDirectory
}

function Tmux-Has-Session() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
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
        [String]
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

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-MacOS in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
