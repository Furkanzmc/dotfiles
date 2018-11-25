#!/usr/bin/env python

"""
Created by Furkan Uzumcu.

As of now, it is only tested on macOS and with the output of Makefiles created
by QMake.

CMake already has an option to create compile_commands.json file.
Just put `set(CMAKE_EXPORT_COMPILE_COMMANDS ON)` in your CMakeLists.txt file.
"""

# Python
import os
import sys
import json

from subprocess import Popen, PIPE

def print_usage():
    print(
        """
Call this from the build directory.

To generate compile commands from the output file:
   ${THIS_SCRIPT}.py compiler.output path/to/compile_commands.json

To run the compiler using this script and use the output to generate the
compile commands:
   ${THIS_SCRIPT}.py /path/to/compile_commands.json (optional) -c ${COMPILE_COMMAND}
   Example:
       ${THIS_SCRIPT}.py ./compile_commands.json -c make -j12

       // compile_commands.json is created in the working directory.
       ${THIS_SCRIPT}.py -c make -j12
        """
    )


def get_file_index(file_path, commands):
    # type: (str, List[dict]) -> int
    """Returns the index of the commands for the given file.

    If not found, returns -1.
    """

    found_index = -1
    index = -1
    for command in commands:
        index += 1
        if command.get('file') == file_path:
            found_index = index
            break

    return found_index


def parse_file(compiler_output, compiler_commands_path):
    is_using_internal_output = isinstance(compiler_output, list)
    if not is_using_internal_output and os.path.exists(compiler_output) is False:
        print('Given file does not exist: %s' % (compiler_output, ))
        return

    commands = []
    # If the file exists, read the existing compile_commands.
    if os.path.exists(compiler_commands_path):
        file_handle = open(compiler_commands_path, 'r')
        commands = json.loads(file_handle.read())
        file_handle.close()

    build_dir = os.getcwd()
    if isinstance(compiler_output, list):
        file_handle = compiler_output
    else:
        file_handle = open(compiler_output, 'r')

    for line in file_handle:
        split_line = line.split(' ')  # type: list[str]
        file_path = os.path.abspath(
            split_line[len(split_line) - 1].strip()
        )  # type: str

        if os.path.exists(file_path) is False or os.path.isfile(file_path) is False:
            continue

        split_line[len(split_line) - 1] = file_path
        # Make all the relative paths absolute.
        index = 0
        new_arguments = []
        for index, item in enumerate(split_line):  # type: int, str
            if os.path.isfile(item) or os.path.isdir(item):
                split_line[index] = os.path.abspath(item)
            # NOTE: For some reason, -isysroot breaks YCM.
            elif item.find('-isysroot') > -1:
                continue
            elif index > 0 and split_line[index - 1].find('-isysroot') > -1:
                continue

            new_arguments.append(split_line[index])

        found_index = get_file_index(file_path, commands)
        command = {
            "directory": build_dir,
            "command": ' '.join(new_arguments).strip(),
            "file": os.path.abspath(file_path.strip())
        }
        if found_index == -1:
            commands.append(command)
        else:
            commands[found_index] = command

    if not is_using_internal_output:
        file_handle.close()

    file_handle = open(compiler_commands_path, 'w')
    file_handle.write(
        json.dumps(commands, sort_keys=True, indent=4, separators=(',', ': '))
    )
    file_handle.close()


def run_compile_program():
    compile_program = sys.argv[sys.argv.index('-c') + 1:]
    if not compile_program:
        print('No compile program is given after the -c option.')
        print_usage()
        return

    process = Popen(compile_program, stdout=PIPE, bufsize=1)
    compile_output = []
    with process.stdout:
        for line in iter(process.stdout.readline, b''):
            print(line)  # Output the process to the terminal.
            compile_output.append(line)

    process.wait()  # wait for the subprocess to exit
    compile_commands_path = './compile_commands.json'
    if sys.argv[1] != '-c':
        compile_commands_path = sys.argv[1]

    parse_file(compile_output, compile_commands_path)


if __name__ == '__main__':
    if '-c' in sys.argv:
        run_compile_program()
    elif len(sys.argv) != 3 or '--help' in sys.argv or '-h' in sys.argv:
        print_usage()
    else:
        parse_file(sys.argv[1], os.path.abspath(sys.argv[2]))
