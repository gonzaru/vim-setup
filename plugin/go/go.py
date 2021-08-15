# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

"""go.py"""

import os
import re
import subprocess
import vim


def go_vet_noexec() -> bool:
    """go_vet_noexec"""
    curbufnr = vim.current.buffer.number
    curbufname = vim.current.buffer.name
    go_vetfilesyntax = vim.eval("s:go_vetfilesyntax")
    # for MyStatusLine()
    vim.command("let s:gv_error = 0")

    if vim.eval("&filetype") != "go":
        print(f"(GOVetNoExec) {curbufname} is no a valid go file!")
        return False

    if not os.path.isfile(go_vetfilesyntax):
        print(f"(GOVetNoExec) {go_vetfilesyntax} is not readable!")
        return False

    vim.command(f"call RemoveSignsName({str(curbufnr)}, 'go_veterror')")

    terrors = 0
    with open(go_vetfilesyntax, "r") as file:
        lines = file.readlines()
        for line in lines:
            if re.match("^vet: ", line):
                errline = line.rstrip("\n").split(":")[2]
                vim.command(
                    f"sign place {errline} line={errline} name=go_veterror \
                    buffer={str(curbufnr)}"
                )
                terrors += 1

    if terrors:
        vim.command("let s:gv_error = " + str(terrors))
    return True
