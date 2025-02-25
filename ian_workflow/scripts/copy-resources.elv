#!/usr/bin/env elvish

var curdir = (pwd)
var pd = $E:HOME/.local/share/pandoc
cp $pd/custom/* $curdir
cp $pd/templates/*.svg $curdir
echo (styled "Copied Pandoc support files to current folder" bold italic yellow)