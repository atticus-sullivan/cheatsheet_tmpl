#!/bin/bash

if [[ "$#" -ne 2 ]] ; then
	echo "Usage: $0 <filename> <section name>"
	exit -1
fi

cp "./sections/example.tex" "./sections/${1}.tex"
sed -i 's/\\section{Example section}/\\section{'"${2}"'}/' "./sections/${1}.tex"

# does not work correctly in general
# line="$(sed -E '/^([[:space:]]*%.*)?$/d' main.tex | sed -nE -e '/^[[:space:]]*\\end\{condMulticols\}[[:space:]]*(%.*)?$/{x;p;d}' -e 'x' | sed -e 's/[\/&]/\\&/g')"
# sed -i '/'"${line}"'/a \\t\\input\{sections\/'"${1}"'\}' main.tex

# set this environment variable to enable this feature
if [[ -n "$INTERACTIVE" ]] ; then
	${EDITOR} "./sections/${1}.tex"
fi
