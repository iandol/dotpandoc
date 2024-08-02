#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Scrivener adds image dimensions for 300DPI images, 
# and doesn't use units
# this makes images too small in LaTeX, and
# typst fails with unitless values
input = $stdin.read
output = input.gsub(/((width|height)=\d+\s*)/, "")
puts output
