#!/usr/bin/env python3

from os.path import expanduser, exists
from subprocess import run

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
                expanduser("~/.vim_runtime/nvim.py"),
                "--change-background",
            ]

            # Themes have space-delimited attributes, one of which will be
            # light or dark.
            parts = theme.split(" ")
            if "dark" in parts:
                preset = await iterm2.ColorPreset.async_get(
                    connection, "cosmic_latte_dark"
                )
                pwsh_args.append("dark")
            else:
                preset = await iterm2.ColorPreset.async_get(
                    connection, "cosmic_latte_light"
                )
                pwsh_args.append("light")

            run(pwsh_args)

            # Update the list of all profiles and iterate over them.
            profiles = await iterm2.PartialProfile.async_query(connection)
            for partial in profiles:
                # Fetch the full profile and then set the color preset in it.
                profile = await partial.async_get_full_profile()
                await profile.async_set_color_preset(preset)


iterm2.run_forever(main)
