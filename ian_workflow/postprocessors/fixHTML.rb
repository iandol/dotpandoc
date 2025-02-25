#!/usr/bin/env ruby
#encoding: utf-8
# This fixes several problems with HTML output

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

output = $stdin.read
# remove these divs if they are empty!
output.gsub!(%r{<div class="correspondence">\s+</div>}, '')
output.gsub!(%r{<div class="author_affiliations">\s+</div>}, '')

puts output
