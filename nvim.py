#!/usr/bin/env python3

# Python
import argparse
from os import getenv, ex
from os.path import expanduser
from typing import List
from logging import getLogger

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
logger.setLevel(getenv("ZMC_DOTFILES_DEBUG_LEVEL", "DEBUG"))


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
            if process_name == "nvim":
                processes.append(process)

    return processes


def create_argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Helper functions to interact with NeoVim"
    )
    parser.add_argument(
        "--change-background",
        type=str,
        help="Change the background of all the NeoVim instances.",
    )
    parser.add_argument(
        "--command", type=str, help="Run a command in all instances.",
    )

    return parser


def run_command(command: str):
    processes = get_nvim_processes()

    process: Process
    for process in processes:
        server = ".vim_runtim/temp_dirs/servers/nvim{}.sock".format(
            expanduser("~"), process.pid
        )
        try:
            nvim = attach("socket", path=server)
        except FileNotFoundError:
            logger.debug("{} server not found.".format(server))
            pass
        else:
            nvim.command(command)


def change_background(mode: str):
    run_command("set background={}".format(mode))


def main():
    args = create_argparser().parse_args()
    if args.change_background:
        change_background(args.change_background)
    if args.command:
        run_command(args.command)


if __name__ == "__main__":
    main()
