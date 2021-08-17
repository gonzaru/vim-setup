# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

"""python.py"""

import os
import subprocess
import vim


def py3_check(mode: str) -> bool:
    """py_check"""
    curbufnr = vim.current.buffer.number
    curbufname = vim.current.buffer.name
    py3_filebuff = vim.eval("s:py3_filebuff")
    py3_filesyntax = vim.eval("s:py3_filesyntax")
    # for MyStatusLine()
    vim.command("let s:py_error = 0")

    if vim.eval("&filetype") != "python":
        raise ValueError(f"(PY3Check) {curbufname} is not valid python file!")

    vim.command(f"call RemoveSignsName({str(curbufnr)}, 'py_error')")

    if mode == "read":
        check_file = curbufname
    elif mode == "write":
        vim.command(f"silent write! {py3_filebuff}")
        check_file = py3_filebuff

    # TODO: adding it native to script
    result = subprocess.run(
        f"python3 -c 'import ast; ast.parse(open(\"{check_file}\").read())' \
        > {py3_filesyntax} 2>&1", shell=True
    )
    if result.returncode != 0:
        vim.command("let s:py_error = 1")
        with open(py3_filesyntax, "r") as file:
            errout = file.readlines()
            errline = errout[4].split(" ")[-1].rstrip()
        errclean = f"SyntaxError: invalid syntax on line {errline}"
        vim.command(
            f"call sign_place({errline}, '', 'py_error', \
            {str(curbufnr)}, {{'lnum' : {errline}}})"
        )
        vim.command(f"call cursor({errline}, 1)")
        raise ValueError(errclean)

    return True


def py3_pep8_noexec() -> bool:
    """py3_pep8_noexec"""
    curbufnr = vim.current.buffer.number
    curbufname = vim.current.buffer.name
    py3_pep8filesyntax = vim.eval("s:py3_pep8filesyntax")
    # for MyStatusLine()
    vim.command("let s:pep8_error = 0")

    if vim.eval("&filetype") != "python":
        print(f"(PY3Pep8NoExec) {curbufname} is no a valid python file!")
        return False

    if not os.path.isfile(py3_pep8filesyntax):
        print(f"(PYPep8NoExec) {py3_pep8filesyntax} is not readable!")
        return False

    vim.command(f"call RemoveSignsName({str(curbufnr)}, 'py_pep8error')")

    terrors = 0
    with open(py3_pep8filesyntax, "r") as file:
        lines = file.readlines()
        for line in lines:
            errline = line.rstrip("\n").split(":")[1]
            vim.command(
                f"call sign_place({errline}, '', 'py_pep8error', \
                {str(curbufnr)}, {{'lnum' : {errline}}})"
            )
            terrors += 1

    if terrors:
        vim.command("let s:pep8_error = " + str(terrors))

    return True
