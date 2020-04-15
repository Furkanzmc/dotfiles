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

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Utils in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}