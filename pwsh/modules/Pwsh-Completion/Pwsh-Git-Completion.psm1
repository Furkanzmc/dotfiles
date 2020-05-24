$GIT_COMMANDS = @()

if (-not $IsMacOS) {
    return
}

# TODO
# [ ] Handle the cases for sub-commands (e.g git stash push)
# [ ] Support range in branch names (e.g master..develop)
# [ ] If there's a file/folder with a name starting with the command, the
#     command completion doesn't work.
# [ ] Once the features are complete for macOS, the commands can be cached for
#     Windows.
function Get-Current-Command($commandComponents, $gitCommands) {
    $commands = ""
    for ($index = 0; $index -lt $commandComponents.Length; $index++) {
        $component = $commandComponents[$index].Trim()
        if ($component -in $gitCommands) {
            $commands += " $component"
        }
    }

    return $commands.Trim()
}

function Get-Git-Commands() {
    $gitCommands = ""
    $allHelp = $(git help -a)
    $allHelp | ForEach-Object {
        $line = $_.Trim()
        if ($line -cmatch "^[a-z]") {
            $command = $line.Trim().Split(" ")[0].Trim()
            $gitCommands += ",$command"
        }
    }

    return $gitCommands.Split(",")
}

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    Param($wordToComplete, $commandAst, $cursorPosition)

    $textToComplete = $commandAst.ToString()
    $textComponents = $textToComplete.Split(" ")

    if ($wordToComplete -match "^-") {
        $tmpManPager = $env:MANPAGER
        $env:MANPAGER = ''

        $helpContent = $(git help $textComponents[$textComponents.Length - 2].Trim())
        $helpContent | ForEach-Object {
            $line = $_.Trim()

            if ($line -cmatch "^-") {
                $result = Select-String -InputObject $line `
                            -Pattern "(--[a-z](-|\w+)+|-[a-z])" -List -AllMatches

                $result.Matches | ForEach-Object {
                    $command = $_
                    if ($command -like "$wordToComplete*") {
                        New-Object -Type System.Management.Automation.CompletionResult `
                            -ArgumentList $command,
                            $command,
                            "ParameterValue",
                            $command
                    }
                }
            }
        }

        $env:MANPAGER = $tmpManPager
        return
    }

    if ($GIT_COMMANDS.Length -eq 0) {
        $gitCommands = Get-Git-Commands
    }
    else {
        $gitCommands = $GIT_COMMANDS
    }

    $currentCommand = Get-Current-Command $textComponents $gitCommands

    $commandCompleted = $false
    if ($currentCommand -eq "") {
        $gitCommands | ForEach-Object {
            $command = $_

            if ($command -like "$wordToComplete*") {
                $commandCompleted = $true
                New-Object -Type System.Management.Automation.CompletionResult `
                    -ArgumentList $command,
                    $command,
                    "ParameterValue",
                    $command
            }
        }

        if ($commandCompleted) {
            return
        }
    }

    $allBranches = $(git branch -a) | ForEach-Object {
        $_.Replace("*", "").Trim().Replace("remotes/", "")
    }
    $localBranches = $(git branch -l) | ForEach-Object {
        $_.Replace("*", "").Trim()
    }

    $branchToComplete = $wordToComplete
    $allBranches | ForEach-Object {
        $branchName = $_
        if ($branchName -like "$branchToComplete*") {
            $trimmed = $branchName.Replace("origin/", "")
            if ($trimmed -in $localBranches) {
                $branchName = $trimmed
            }

            if (-not $branchName.Contains("origin/HEAD")) {
                New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $branchName,
                    $branchName,
                    "ParameterValue",
                    $branchName
            }
        }
    }
}
