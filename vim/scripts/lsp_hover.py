from subprocess import run
from typing import List
from argparse import ArgumentParser, Namespace
from os.path import expanduser


def parse_args() -> Namespace:
    parser = ArgumentParser(description="Process some integers.")
    parser.add_argument(
        "--describe-code",
        type=str,
        help="Outputs the description of the given pytlint error code.",
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


def describe_pylint_code(code: str) -> None:
    if code.find("=") > -1:
        code = code[code.find("=") + 1 :]

    code = code.strip().replace("=", "")
    first_index = -1
    last_index = -1
    lines = get_pylint_output()

    index: int
    line: str
    for index, line in enumerate(lines):
        if line.find(code) >= 0:
            first_index = index
        elif first_index >= 0 and line.startswith(":"):
            last_index = index
            break

    if first_index > -1:
        print("\n".join(lines[first_index:last_index]))
    else:
        print("No description for {}.".format(code))


def main() -> None:
    args = parse_args()
    if args.describe_code:
        describe_pylint_code(args.describe_code)


if __name__ == "__main__":
    main()
