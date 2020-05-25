function Get-Current-Command($commandComponents, $availableCommands) {
    $commands = ""
    for ($index = 0; $index -lt $commandComponents.Length; $index++) {
        $component = $commandComponents[$index].Trim()
        if ($component -in $availableCommands) {
            $commands += " $component"
        }
    }

    return $commands.Trim()
}

# Helper function to update the commands from the django-admin executable.
# It's called manually and the results are saved in the script.
function Build-Help-Registry() {
    $commands = $(django-admin help --commands)
    $commandMap = @{}
    $commands | ForEach-Object {
        $command = $_
        $output = $(django-admin help $command)
        $options = ""
        $output | ForEach-Object {
            $line = $_
            $result = Select-String -InputObject $line `
                -Pattern "(--[a-z](-|\w+)+|-[a-z])" -List -AllMatches

            $result.Matches | ForEach-Object {
                if ($_ -and -not $options.Contains($_)) {
                    $trimmed = $_.Value.Trim()
                    $options += ",$trimmed"
                }
            }

            $commandMap[$command] = $options.Trim().Split(",")
        }
    }

    return $commandMap
}

function Complete() {
    Param($app, $wordToComplete, $commandAst, $cursorPosition)

    $textToComplete = $commandAst.ToString()
    $textComponents = $textToComplete.Split(" ")
    if ($textComponents.Length -lt 2) {
        return
    }

    if ($app -eq "python" -and -not $textComponents[1] -contains "manage.py") {
        return
    }

    # Commands are from Django 1.10.
    $commands = @{
        "check"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--tag",
            "--list-tags",
            "--deploy",
            "--fail-level",
            "--help",
            "--verbosity",
            "-z"
        )
        "sqlflush"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--help",
            "--verbosity"
        )
        "dbshell"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "-l",
            "--help",
            "--verbosity"
        )
        "showmigrations"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--list",
            "--plan",
            "--help",
            "--verbosity"
        )
        "sqlmigrate"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--backwards",
            "--help",
            "--verbosity"
        )
        "migrate"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--noinput",
            "--database",
            "--fake",
            "--fake-initial",
            "--run-syncdb",
            "--help",
            "--verbosity",
            "--no-input"
        )
        "dumpdata"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--format",
            "--indent",
            "--database",
            "-e",
            "--natural-foreign",
            "--natural-primary",
            "--pks",
            "-o",
            "--all",
            "--help",
            "--verbosity",
            "--exclude",
            "--output"
        )
        "sendtestemail"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--managers",
            "--admins",
            "--help",
            "--verbosity"
        )
        "inspectdb"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--help",
            "--verbosity"
        )
        "diffsettings"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--all",
            "--help",
            "--verbosity"
        )
        "compilemessages"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--locale",
            "--exclude",
            "--use-fuzzy",
            "--help",
            "--verbosity",
            "-x"
        )
        "startproject"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--template",
            "--extension",
            "--name",
            "--help",
            "--verbosity"
        )
        "squashmigrations"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--no-optimize",
            "--noinput",
            "--help",
            "--verbosity",
            "--no-input"
        )
        "makemigrations"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--dry-run",
            "--merge",
            "--empty",
            "--noinput",
            "--check",
            "--help",
            "--verbosity",
            "--no-input",
            "--name",
            "--exit",
            "-z"
        )
        "loaddata"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--app",
            "--ignorenonexistent",
            "--help",
            "--verbosity"
        )
        "runserver"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--ipv6",
            "--nothreading",
            "--noreload",
            "--help",
            "--verbosity",
            "-r"
        )
        "test"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--noinput",
            "--failfast",
            "--testrunner",
            "--liveserver",
            "-k",
            "-r",
            "-d",
            "--parallel",
            "--tag",
            "--exclude-tag",
            "--help",
            "--verbosity",
            "--no-input",
            "--top-level-directory",
            "--pattern",
            "--keepdb",
            "--reverse",
            "--debug-sql"
        )
        "makemessages"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--locale",
            "--exclude",
            "--domain",
            "--all",
            "--extension",
            "--symlinks",
            "--ignore",
            "--no-default-ignore",
            "--no-wrap",
            "--no-location",
            "--no-obsolete",
            "--keep-pot",
            "--help",
            "--verbosity",
            "-x"
        )
        "startapp"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--template",
            "--extension",
            "--name",
            "--help",
            "--verbosity"
        )
        "shell"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--plain",
            "--no-startup",
            "-i",
            "--help",
            "--verbosity",
            "--interface",
            "--command"
        )
        "testserver"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--noinput",
            "--addrport",
            "--ipv6",
            "--help",
            "--verbosity",
            "--no-input"
        )
        "createcachetable"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--dry-run",
            "--help",
            "--verbosity"
        )
        "flush"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--noinput",
            "--database",
            "--help",
            "--verbosity",
            "--no-input"
        )
        "sqlsequencereset"=@(
            "-a",
            "-h",
            "--version",
            "--settings",
            "--pythonpath",
            "--traceback",
            "--no-color",
            "--database",
            "--help",
            "--verbosity"
        )
    }

    $currentCommand = Get-Current-Command $textComponents $commands.Keys
    if ($currentCommand -eq "") {
        $commands.Keys | ForEach-Object {
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
    elseif ($wordToComplete.StartsWith("-")) {
        $options = $commands[$currentCommand]
        $options | ForEach-Object {
            $option = $_
            if ($option -like "$wordToComplete*") {
                New-Object -Type System.Management.Automation.CompletionResult `
                    -ArgumentList $option,
                    $option,
                    "ParameterValue",
                    $option
            }
        }
    }

}

Register-ArgumentCompleter -Native -CommandName python -ScriptBlock {
    Param($wordToComplete, $commandAst, $cursorPosition)
    Complete "python" $wordToComplete $commandAst $cursorPosition
}

Register-ArgumentCompleter -Native -CommandName django-admin -ScriptBlock {
    Param($wordToComplete, $commandAst, $cursorPosition)
    Complete "django-admin" $wordToComplete $commandAst $cursorPosition
}
