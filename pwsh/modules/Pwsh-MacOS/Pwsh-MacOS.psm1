if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

$env:EDITOR = 'nvim'
$global:ICLOUD = "~/Library/Mobile Documents/com~apple~CloudDocs/"

function Is-Dark-Mode() {
    $output = (~/.dotfiles/scripts/Is-Dark-Theme.osascript) | Out-String
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

function Toggle-Dark-Mode() {
    (~/.dotfiles/scripts/Toggle-Dark-Mode.osascript) | Out-Null
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

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-MacOS in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
