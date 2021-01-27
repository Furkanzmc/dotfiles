from subprocess import run
from typing import List
from argparse import ArgumentParser, Namespace
from os.path import expanduser
from urllib.request import urlopen


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
        help="Outputs word definition.",
    )

    parser.add_argument(
        "--hover",
        type=str,
        help="Runs all the hover functions one by one until one returns output",
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
    output = (
        run(["curl", 'dict://dict.org/d:"{}"'.format(word)], capture_output=True)
        .stdout.decode("utf-8")
        .split("\n")
    )

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


def main() -> None:
    args = parse_args()
    if args.describe_code:
        describe_pylint_code(args.describe_code)
    elif args.define:
        define_word(args.define)
    elif args.hover:
        hover(args.hover, args.language)


if __name__ == "__main__":
    main()
