#!/bin/zsh

texmf=`kpsewhich -var-value=TEXMFHOME`
if [[ ! -d $texmf/tex/latex/kaobook]]; then
	mkdir -p $texmf/tex/latex
	cd $texmf/tex/latex
	git clone https://github.com/fmarotta/kaobook.git kaobook
fi
