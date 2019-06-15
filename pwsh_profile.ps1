# Import Modules
Import-Module PSReadLine
Import-Module posh-git
if ($IsWindows) {
    Import-Module Pscx
}

# Functions
function export($name, $value) {
    [System.Environment]::SetEnvironmentVariable($name, $value)
}

function replace_in_dir($from, $to) {
    if ($IsMacOS) {
        rg -l -F "$from" | xargs sed -i -e "s/$from/$to/g"
    }
    else {
        Write-Host 'replace_in_dir is not supported on this platform.'
    }
}

if ($IsMacOS) {
    $env:PATH += ":/usr/local/bin"

    export EDITOR 'nvim'

    if (Test-Path '/usr/local/bin/exa') {
        Set-Alias ls /usr/local/bin/exa
    }

    if (Test-Path '/usr/local/bin/fd') {
        Set-Alias find /usr/local/bin/fd
    }

    if (Test-Path '/usr/local/bin/bat') {
        Set-Alias cat /usr/local/bin/bat
    }

    if (Test-Path '/usr/local/bin/nvim') {
        Set-Alias vim /usr/local/bin/nvim
    }

    function post-notification($message, $title) {
        osascript -e "display notification \`"$message\`" with title \`"$title\`""
    }

    function cd-icloud() {
        cd "~/Library/Mobile Documents/com~apple~CloudDocs/"
    }

    alias lock_screen="/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession -suspend"
} # End MacOS

if ($IsWindows) {
    $Shell = $Host.UI.RawUI
    $size = $Shell.WindowSize
    $size.width=90
    $size.height=90
    $Shell.WindowSize = $size
    $size = $Shell.BufferSize
    $size.width=90
    $size.height=5000
    $Shell.BufferSize = $size
} # End Windows

function cd-desktop() {
    cd ~/Desktop
}

function cd-downloads() {
    cd ~/Downloads
}

# Returns the direct download link for a Google Drive share link.
function gdocs2d($url) {
    $subs = "/d/"
    $index = $url.IndexOf($subs)
    $url = $url.Substring(
        $index + $subs.length,
        $url.length - ($index + $subs.length)
    )
    $index = $url.IndexOf("/")
    $fileID = $url.Substring(0, $index)
    $url = "https://drive.google.com/uc?export=download&id=$fileID"
    return $url
}

# Git
git config --global alias.st 'status'
git config --global alias.stage 'add'
git config --global alias.unstage 'reset HEAD --'

git config --global alias.last 'log -1 HEAD'
git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

git config --global alias.logpretty "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.tasks "!rg 'TODO|FIXME' ./"
git config --global alias.discard 'checkout --'

function git-difflog($from, $to) {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --name-status $from..$to
}

git config --global color.status.changed "magenta normal bold"
git config --global color.status.added "blue normal bold"
git config --global color.status.unmerged "yellow normal bold"

function git-set-author($name, $email) {
    git config user.name "$name"
    git config user.email "$email"
}

# Module Configurations

## Posh-Git Configuration
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true
$GitPromptSettings.EnableFileStatus = $false
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = ':`n'
$GitPromptSettings.DefaultPromptSuffix = '$("=>" * ($nestedPromptLevel + 1)) '

## PSReadLine Options

$PSReadLineOptions = @{
    EditMode = "Vi"
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
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
