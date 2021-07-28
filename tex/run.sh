#!/bin/bash

PROJECTPATH="/home/stein/my/prj/textemplate"
BUILDPATH=${PROJECTPATH}"/tex"
MYPRJ="thesis"
LUAOPTIONS='--halt-on-error --output-format="pdf" --shell-escape --synctex=1 --interaction=nonstopmode'
FILTER="\(.sty\|/usr/local/texlive/2021/texmf-dist/tex\|loading\)"
DATE=`date +%Y-%m-%d_T%H%M%S`

max_print_line=1000
error_line=254
half_error_line=238

die() {
  echo "$@" 1>&2
  savelog "failed"
  exit 1
}

savelog() {
  cp ${BUILDPATH}/thesis.log ${BUILDPATH}/logs/${DATE}_step${1}.log
}

monitor() {
TIME_STYLE=long-iso ls -1l ${BUILDPATH} > /tmp/tex_run${1}.log
savelog ${1}
}

printstep(){
echo -ne "\033]0; TeX Step ${1}\007"
}

step=1
monitor ${step}

step=$((step+1))
printstep ${step}
latexmk -c || die "run.sh: latexmk -c failed"
rm -f ${BUILDPATH}/thesis.synctex.gz
monitor ${step}

step=$((step+1))
printstep ${step}
cp -f ${PROJECTPATH}/bib/literature.bib ${BUILDPATH}/literature.bib || die "cp .bib failed"
sort acronym.tex > acronym_sorted.tex && mv acronym_sorted.tex acronym.tex
monitor ${step}

step=$((step+1))
printstep ${step}
lualatex ${LUAOPTIONS} ${MYPRJ}.tex || die "run.sh: first lualatex run failed"
monitor ${step}

step=$((step+1))
printstep ${step}
biber ${MYPRJ}.bcf || die "run.sh: biber failed" 
monitor ${step}

step=$((step+1))
printstep ${step}
#xindy ${MYPRJ}.idx
monitor ${step}

step=$((step+1))
printstep ${step}
#makeglossaries ${MYPRJ} || die "run.sh: makeglossaries failed"
monitor ${step}

step=$((step+1))
printstep ${step}
lualatex ${LUAOPTIONS} ${MYPRJ}.tex || die "run.sh: second lualatex run failed"
monitor ${step}

step=$((step+1))
printstep ${step}
lualatex ${LUAOPTIONS} ${MYPRJ}.tex || die "run.sh: third lualatex run failed"
monitor ${step}

step=$((step+1))
printstep ${step}

