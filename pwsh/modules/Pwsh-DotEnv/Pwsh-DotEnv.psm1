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
    if ($lines.GetType().Name -eq "String") {
        $lines = $lines.Split("\n")
    }

    for ($index = 0; $index -lt $lines.Length; $index++) {
        $line = $lines[$index]
        $parts = _Get-Env-Var-Parts $line
        if ($parts.Length -eq 0) {
            continue
        }

        if ($Load) {
            $name = "env:" + $parts[0]
            $value = $parts[1]
            Set-Item -Path $name -Value $value
        }
        else {
            Remove-Item -Path "env:$parts[0]"
        }
    }
}

function Source-Env() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path
    )

    Dotenv $Path -Load $true
}

function Deactivate-Env() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path
    )

    Dotenv $Path -Load $false
}

Export-ModuleMember -Function Source-Env
Export-ModuleMember -Function Deactivate-Env

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-DotEnv in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
