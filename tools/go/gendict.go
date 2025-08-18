package main

import (
	"bufio"
	"flag"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

// runGoList
func runGoList(pattern string) ([][2]string, error) {
	cmd := exec.Command("go", "list", "-f", "{{.ImportPath}}\t{{.Dir}}", pattern)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	var res [][2]string
	for _, ln := range lines {
		if ln == "" {
			continue
		}
		i := strings.IndexRune(ln, '\t')
		if i <= 0 {
			continue
		}
		ip := ln[:i]
		dir := ln[i+1:]
		if ip != "" && dir != "" {
			res = append(res, [2]string{ip, dir})
		}
	}
	return res, nil
}

// isExported
func isExported(name string) bool {
	if name == "" {
		return false
	}
	r := rune(name[0])
	return r >= 'A' && r <= 'Z'
}

// collectSymbols
func collectSymbols(pairs [][2]string) []string {
	syms := make(map[string]struct{}, 1<<14)
	fset := token.NewFileSet()

	for _, p := range pairs {
		ip, dir := p[0], p[1]
		if ip == "" || dir == "" {
			continue
		}
		entries, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, e := range entries {
			if e.IsDir() {
				continue
			}
			name := e.Name()
			if !strings.HasSuffix(name, ".go") || strings.HasSuffix(name, "_test.go") {
				continue
			}
			path := filepath.Join(dir, name)
			file, err := parser.ParseFile(fset, path, nil, 0)
			if err != nil || file == nil {
				continue
			}

			for _, decl := range file.Decls {
				switch d := decl.(type) {
				case *ast.GenDecl:
					if d.Tok == token.TYPE {
						for _, spec := range d.Specs {
							if ts, ok := spec.(*ast.TypeSpec); ok {
								if isExported(ts.Name.Name) {
									syms[ip+"."+ts.Name.Name] = struct{}{}
								}
							}
						}
					}
				case *ast.FuncDecl:
					if d.Recv == nil {
						if isExported(d.Name.Name) {
							syms[ip+"."+d.Name.Name] = struct{}{}
						}
					} else {
						if isExported(d.Name.Name) {
							syms[ip+"."+d.Name.Name] = struct{}{}
						}
					}
				}
			}
		}
	}

	list := make([]string, 0, len(syms))
	for k := range syms {
		list = append(list, k)
	}
	sort.Strings(list)
	return list
}

// writeLines
func writeLines(path string, lines []string) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	w := bufio.NewWriter(f)
	for _, s := range lines {
		if _, err := fmt.Fprintln(w, s); err != nil {
			return err
		}
	}
	return w.Flush()
}

// main
func main() {
	modOut := flag.String("modout", "go-project.dict", "output file")
	stdOut := flag.String("stdout", "go-stdlib.dict", "output file")
	flag.Parse()

	used := map[string]bool{}
	flag.Visit(func(f *flag.Flag) {
		used[f.Name] = true
	})

	// if -stdout go-stdlib.dict else go-project.dict
	if used["stdout"] {
		var stdPairs [][2]string
		if pairs, err := runGoList("std"); err == nil {
			stdPairs = pairs
		}
		stdSyms := collectSymbols(stdPairs)
		if err := writeLines(*stdOut, stdSyms); err != nil {
			fmt.Fprintf(os.Stderr, "error writting %s: %v\n", *stdOut, err)
			os.Exit(1)
		}
	} else {
		var modPairs [][2]string
		if pairs, err := runGoList("./..."); err == nil {
			modPairs = pairs
		}
		modSyms := collectSymbols(modPairs)
		if err := writeLines(*modOut, modSyms); err != nil {
			fmt.Fprintf(os.Stderr, "error writting %s: %v\n", *modOut, err)
			os.Exit(1)
		}
	}

	//fmt.Printf("OK: %s (%d entries)\n", *stdOut, len(stdSyms))
	//fmt.Printf("OK: %s (%d entries)\n", *modOut, len(modSyms))
}
