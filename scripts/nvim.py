#!/usr/bin/env python3

# Python
import argparse
from os import getenv, name as os_name
from os.path import expanduser
from typing import List
from logging import getLogger, Logger, DEBUG

# Thid Party
from pynvim import attach
from psutil import (
    process_iter,
    NoSuchProcess,
    AccessDenied,
    ZombieProcess,
    Process,
)

logger: Logger = getLogger("zmc.dotfiles.nvim")
logger.setLevel(getenv("ZMC_DOTFILES_DEBUG_LEVEL", DEBUG))


def get_nvim_processes() -> List[Process]:
    processes: List[Process] = []

    process: Process
    for process in process_iter():
        try:
            process_name = process.name()
        except (
            NoSuchProcess,
            AccessDenied,
            ZombieProcess,
        ):
            pass
        else:
            if process_name == "nvim.exe" or process_name == "nvim":
                processes.append(process)

    return processes


def create_argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Helper functions to interact with NeoVim"
    )
    parser.add_argument(
        "--command", type=str, help="Run a command in all instances.",
    )

    return parser


def run_command(command: str):
    processes = get_nvim_processes()

    logger.debug("Running command: {}".format(command))
    process: Process
    for process in processes:
        if os_name == "nt":
            server: str = "//./pipe/nvim-{}".format(process.pid)
        else:
            server: str = expanduser(
                "~/.dotfiles/vim/temp_dirs/servers/nvim{}.sock".format(process.pid)
            )

        try:
            with attach("socket", path=server) as nvim:
                nvim.command(command)
        except:
            logger.debug("{} server not found.".format(server))


def main():
    args = create_argparser().parse_args()
    logger.debug("Args: {}".format(args))
    if args.command:
        run_command(args.command)


if __name__ == "__main__":
    main()
