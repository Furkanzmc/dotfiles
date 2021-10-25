from subprocess import run
from typing import List, Optional, Tuple
from argparse import ArgumentParser, Namespace
from os.path import expanduser
from distutils.spawn import find_executable
from sys import stdin, stdout
from re import compile as compile_regex
import asyncio
import logging
from datetime import datetime
from os import getenv
from math import ceil

logging.basicConfig(
    filename=expanduser("~/.dotfiles/vim/temp_dirs/tmp_files/lsp.log"),
    encoding="utf-8",
    level=logging.getLevelName(getenv("VIMRC_LSP_LOG_LEVEL", "ERROR")),
)


class FunctionTiming(object):
    def __init__(self, method):
        self.start_time = datetime.now()
        self.method = method

    def __enter__(self):
        return self.start_time

    def __exit__(self, type, value, traceback):
        end_time = datetime.now()
        delta = end_time - self.start_time

        logging.debug(
            "Finished %s: %s ms",
            self.method,
            delta.total_seconds() * 1000,
        )


def parse_args() -> Namespace:
    parser = ArgumentParser(description="Process some integers.")
    parser.add_argument(
        "--describe-code",
        type=str,
        help="Outputs the description of the given pytlint error code.",
    )

    parser.add_argument(
        "--define",
        type=str,
        help="Outputs word definition.",
    )

    parser.add_argument(
        "--language",
        type=str,
        default=None,
        help="Specify which language is used for completion.",
    )

    parser.add_argument(
        "--hover",
        type=str,
        help="Runs all the hover functions one by one until one returns output",
    )

    parser.add_argument(
        "--complete",
        action="store_true",
        help="Runs the completion commands.",
    )

    parser.add_argument(
        "--position",
        type=str,
        help="l:c position of the cursor.",
    )

    return parser.parse_args()


def get_pylint_output() -> List[str]:
    try:
        output = open(
            expanduser("~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt"), "r"
        ).read()
    except IOError:
        output = run(["pylint", "--list-msgs"], capture_output=True).stdout.decode(
            "utf-8"
        )

    return output.split("\n")


def describe_pylint_code(code: str) -> bool:
    if code.find("=") > -1:
        code = code[code.find("=") + 1 :]

    code = code.strip().replace("=", "")
    first_index = -1
    last_index = -1
    lines = get_pylint_output()

    index: int
    line: str
    for index, line in enumerate(lines):
        if line.find("({})".format(code)) >= 0:
            first_index = index
        elif first_index >= 0 and line.startswith(":"):
            last_index = index
            break

    if first_index > -1:
        print("\n".join(lines[first_index:last_index]))
        return True

    return False


def define_word(word: str) -> bool:
    output: List[str] = [
        line.rstrip("\r")
        for line in run(
            ["curl", 'dict://dict.org/d:"{}"'.format(word)], capture_output=True
        )
        .stdout.decode("utf-8")
        .split("\n")
    ]

    first_index = -1
    for index, line in enumerate(output):
        if line.startswith("552"):
            break

        if line.startswith("150"):
            first_index = index + 1
            break

    if first_index > -1:
        print("\n".join(output[first_index:]))
        return True

    return False


def pydoc(word: str) -> bool:
    if not find_executable("pydoc"):
        return False

    result = run(["pydoc", word], capture_output=True)
    if result.returncode == 0:
        output = result.stdout.decode("utf-8")
        if output.find("no Python documentation found for") == -1:
            print(output)
            return True

    return False


def hover(token: str, language: str = None):
    if language == "python" and describe_pylint_code(token):
        return

    if language == "python" and pydoc(token):
        return

    if language not in ("python",) and define_word(token):
        return


def complete(contents: List[str], position: str, language: Optional[str] = None):
    if not position:
        raise ValueError("position is required.")

    pos: List[int] = [int(item) for item in position.split(":")]
    linenr: int = pos[0]
    base, start_pos, end_pos = get_base(contents[linenr], pos[1])
    contents[linenr] = contents[linenr][start_pos:end_pos]

    with FunctionTiming("complete:tokenize"):
        output: bytes = tokenize_regex_async(contents)

    with FunctionTiming("complete:fzf"):
        output = run(
            ["fzf", "-i", "--filter", base],
            capture_output=True,
            input=output,
        ).stdout

    if not output:
        return

    with FunctionTiming("complete:sort"):
        completions: str = "\n".join(sorted(set(output.decode("utf-8").split("\n"))))

    if completions:
        print(completions)


def main() -> None:
    args = parse_args()
    if args.describe_code:
        describe_pylint_code(args.describe_code)
    elif args.define:
        define_word(args.define)
    elif args.hover:
        hover(args.hover, args.language)
    elif args.complete:
        with FunctionTiming("complete()"):
            complete(get_contents_from_stdin(), args.position, args.language)


def get_contents_from_stdin() -> List[str]:
    contents: List[str] = []
    try:
        for line in iter(stdin.readline, ""):
            contents.append(line)
    except KeyboardInterrupt:
        stdout.flush()
        exit(0)

    return contents


def get_base(line: str, start_pos: int) -> Tuple[str, int, int]:
    index: int = start_pos
    base: str = ""
    while not base:
        if line[index] in ("", ".", ">", " ") or index == 0:
            base = line[index + 1 * (index != "") :]
            break

        index = index - 1

    return (base.strip(), start_pos, index)


def tokenize_regex(contents: List[str]) -> bytes:
    pattern = compile_regex("\\w+")
    tokens: List[str] = pattern.findall("\n".join(contents))

    return "\n".join(tokens).encode("utf-8")


def tokenize_regex_async(contents: List[str]) -> bytes:
    pattern = compile_regex("\\w+")
    tokens: List[str] = []

    async def tokenize(lines: List[str]) -> List[str]:
        return pattern.findall("\n".join(lines))

    loop = asyncio.get_event_loop()
    tasks: List[asyncio.Task] = []

    size = len(contents)
    count = 12
    step_size = int(ceil(len(contents) / count))
    taken_count = 0
    index = 0
    while index < count:
        taken_count = min(size, taken_count + (step_size * index))
        lines = contents[taken_count : taken_count + step_size]
        tasks.append(loop.create_task(tokenize(lines)))
        index = index + 1

    assert taken_count == size, "{} != {}".format(taken_count, size)
    done, _ = loop.run_until_complete(asyncio.wait(tasks))
    for future in done:
        tokens.extend(future.result())

    loop.close()

    return "\n".join(tokens).encode("utf-8")


def tokenize_rg(contents: List[str]) -> bytes:
    output = run(
        [
            "rg",
            "\\w+",
            "--no-filename",
            "--no-column",
            "--no-line-number",
            "--only-matching",
        ],
        capture_output=True,
        input="\n".join(contents).encode("utf-8"),
    ).stdout

    return output


if __name__ == "__main__":
    main()
