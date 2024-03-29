#!/usr/bin/env python3

# Python
from os.path import expanduser, exists
from subprocess import run

# iterm
import iterm2


async def main(connection):
    async with iterm2.VariableMonitor(
        connection, iterm2.VariableScopes.APP, "effectiveTheme", None
    ) as mon:
        while True:
            # Block until theme changes
            theme = await mon.async_get()

            if exists("/usr/bin/python3"):
                python_path = "/usr/bin/python3"
            elif exists("/usr/local/bin/python3"):
                python_path = "/usr/local/bin/python3"
            else:
                raise RuntimeError("Cannot find python3 executable.")

            pwsh_args = [
                python_path,
                expanduser("~/.dotfiles/scripts/nvim.py"),
                "--command",
            ]

            # Themes have space-delimited attributes, one of which will be
            # light or dark.
            parts = theme.split(" ")
            if "dark" in parts:
                preset = await iterm2.ColorPreset.async_get(
                    connection, "catppuccin_frappe"
                )
                pwsh_args.append("set background=dark")
                with open(
                    expanduser("~/.dotfiles/pwsh/tmp_dirs/system_theme"), "w"
                ) as file_handle:
                    file_handle.write("dark")
            else:
                preset = await iterm2.ColorPreset.async_get(
                    connection, "catppuccin_latte"
                )
                pwsh_args.append("set background=light")
                with open(
                    expanduser("~/.dotfiles/pwsh/tmp_dirs/system_theme"), "w"
                ) as file_handle:
                    file_handle.write("light")

            run(pwsh_args)

            # Update the list of all profiles and iterate over them.
            profiles = await iterm2.PartialProfile.async_query(connection)
            for partial in profiles:
                # Fetch the full profile and then set the color preset in it.
                profile = await partial.async_get_full_profile()
                await profile.async_set_color_preset(preset)


iterm2.run_forever(main)
