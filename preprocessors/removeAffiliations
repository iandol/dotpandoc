#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# This removes an affiliation paragraph if present, 
# as LaTeX will generate this from the metadata
input = $stdin.read
output = input.gsub(/(^[\*]?Affiliations[^\n]+)/, "\n")

puts output
