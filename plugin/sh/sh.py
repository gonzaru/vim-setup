# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

"""sh.py"""

import os
import re
import subprocess
import vim


def sh_check(mode: str) -> bool:
    """sh_check"""
    curbufnr = vim.current.buffer.number
    curbufname = vim.current.buffer.name
    sh_filebuff = vim.eval("s:sh_filebuff")
    sh_filesyntax = vim.eval("s:sh_filesyntax")
    default_shell = "sh"
    # for MyStatusLine()
    vim.command("let s:sh_error = 0")

    if vim.eval("&filetype") != "sh":
        raise ValueError(f"(SHCheck) {curbufname} is no a valid sh file!")

    vim.command(f"call RemoveSignsName({str(curbufnr)}, 'sh_error')")

    # get the shell from #shebang
    if re.match(r".*[\/\s]{1}bash$", vim.current.buffer[0]):
        theshell = "bash"
    elif re.match(r".*[\/\s]{1}sh$", vim.current.buffer[0]):
        theshell = "sh"
    else:
        theshell = default_shell

    if theshell != "sh" and theshell != "bash":
        raise ValueError("(SHCheck) unknow shell!")

    if mode == "read":
        check_file = curbufname
    elif mode == "write":
        vim.command(f"silent write! {sh_filebuff}")
        check_file = sh_filebuff

    if theshell == "sh":
        result = subprocess.run(
            f"sh -n {check_file}  > {sh_filesyntax} 2>&1",
            shell=True,
        )
    elif theshell == "bash":
        result = subprocess.run(
            f"bash --norc -n {check_file}  > {sh_filesyntax} 2>&1",
            shell=True,
        )

    if result.returncode != 0:
        vim.command("let s:sh_error = 1")
        with open(sh_filesyntax, "r") as file:
            errout = file.readline().rstrip()
        if theshell == "sh":
            errline = errout.split(":")[1].strip()
        elif theshell == "bash":
            errline = errout.split(":")[1].split(" ")[2]
        errclean = f"{errline} : " + "".join(errout.split(":")[-2:])
        vim.command(
            f"call sign_place({errline}, '', 'sh_error', \
            {str(curbufnr)}, {{'lnum' : {errline}}})"
        )
        vim.command(f"call cursor({errline}, 1)")
        raise ValueError(errclean)

    return True


def sh_shellcheck_noexec() -> bool:
    """sh_shellcheck_noexec"""
    curbufnr = vim.current.buffer.number
    curbufname = vim.current.buffer.name
    sh_shellcheckfilesyntax = vim.eval("s:sh_shellcheckfilesyntax")
    # for MyStatusLine()
    vim.command("let s:sc_error = 0")

    if vim.eval("&filetype") != "sh":
        print(f"(SHShellCheckNoExec) {curbufname} is no a valid sh file!")
        return False

    if not os.path.isfile(sh_shellcheckfilesyntax):
        print(
            f"(SHShellCheckNoExec){sh_shellcheckfilesyntax} is not readable!"
        )
        return False

    vim.command(f"call RemoveSignsName({str(curbufnr)}, 'sh_shellcheckerror')")

    terrors = 0
    with open(sh_shellcheckfilesyntax, "r") as file:
        lines = file.readlines()
        for line in lines:
            if re.match("^In ", line):
                errline = line.rstrip("\n").split(" ")[3].split(":")[0]
                vim.command(
                    f"call sign_place({errline}, '', 'sh_shellcheckerror', \
                    {str(curbufnr)}, {{'lnum' : {errline}}})"
                )
                terrors += 1
    if terrors:
        vim.command("let s:sc_error = " + str(terrors))

    return True
