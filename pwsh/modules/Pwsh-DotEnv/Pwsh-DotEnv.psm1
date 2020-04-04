if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

function _Get-Env-Var-Parts($line) {
    $equalsIndex = $line.IndexOf("=")
    if ($equalsIndex -eq -1) {
        return @()
    }

    $var = $line.Substring(0, $equalsIndex).Trim()
    $value = $line.Substring($equalsIndex + 1).Trim()
    if ($value[0] -eq '"' -and $value[$value.Length - 1] -eq '"') {
        $value = $value.Trim('"')
    }

    return @($var, $value)
}

function Dotenv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $Load=$true
    )

    $lines = Get-Content -Path $Path
    for ($index = 0; $index -lt $lines.Length; $index++) {
        $line = $lines[$index]
        $parts = _Get-Env-Var-Parts $line
        if ($parts.Length -eq 0) {
            continue
        }

        if ($Load) {
            Set-Item -Path "env:$parts[0]" -Value $parts[1]
        }
        else {
            Remove-Item -Path "env:$parts[0]"
        }
    }
}

function Load-Dotenv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path
    )

    Dotenv $Path -Load $true
}

function Unload-Dotenv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path
    )

    Dotenv $Path -Load $false
}


Export-ModuleMember -Function Load-Dotenv
Export-ModuleMember -Function Unload-Dotenv

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-DotEnv in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
