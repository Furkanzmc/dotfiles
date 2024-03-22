if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

function Ffmpeg-Create-Time-Lapse() {
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
        $OutExtension="mov",
        [Parameter(Mandatory=$true)]
        [String]
        $Framerate=10
    )

    $files = $(Get-ChildItem -Name -Filter *.$SourceExtension -Path $SourceDir)
    $files | ForEach-Object {
        Remove-Item -Path "$FramesOutDir/*"
        if ($_ -ne $Entry) {
            ffmpeg -i "$SourceDir/$_" -vf fps=2 "$FramesOutDir/%06d.png"
            if ($?) {
                ffmpeg -framerate $Framerate -i "$FramesOutDir/%06d.png" "$OutDir/$_.$OutExtension"
            }
        }
    }
}

function Ffmpeg-Merge-Videos() {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $InputFile,
        [Parameter(Mandatory=$true)]
        [String]
        $Out
    )

    ffmpeg -f concat -i $InputFile -c copy $Out
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Utils in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
