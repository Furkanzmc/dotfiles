#!/usr/bin/env python

"""
Created by Furkan Uzumcu.
"""

# Python
import json
import sys
import os


def print_usage():
    print(
        """
Call this from the build directory.
Usage:
    c_cmd.py compiler.output path/to/compile_commands.json
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


def parse_file():
    compiler_output = sys.argv[1]
    if os.path.exists(compiler_output) is False:
        print('Given file does not exist: %s' % (compiler_output, ))
        return

    commands = []
    # If the file exists, read the existing compile_commands.
    compiler_commands_path = os.path.abspath(sys.argv[2])
    if os.path.exists(compiler_commands_path):
        file_handle = open(compiler_commands_path, 'r')
        commands = json.loads(file_handle.read())
        file_handle.close()

    build_dir = os.getcwd()
    file_handle = open(compiler_output, 'r')
    for line in file_handle:
        split_line = line.split(' ')  # type: list
        file_path = os.path.abspath(
            split_line[len(split_line) - 1].strip()
        )  # type: str
        if os.path.exists(file_path) is False:
            continue
        if os.path.isfile(file_path) is False:
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

    file_handle.close()
    file_handle = open(compiler_commands_path, 'w')
    file_handle.write(
        json.dumps(commands, sort_keys=True, indent=4, separators=(',', ': '))
    )
    file_handle.close()

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print_usage()
    else:
        parse_file()
