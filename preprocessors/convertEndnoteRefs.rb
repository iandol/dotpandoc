#!/usr/bin/env ruby
#encoding: utf-8

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# the job of this preproceccer is to convert endnote citations to pandoc citations.
# It assumes your BibTeX keys are authorYear and will not be able to handle collisions
# as endnote uses unique IDs which cannot be used in the bib file easily.
input = $stdin.read
# this regex matches {Letter ... Number} should get endnote refs but not overmatch, replace with brackets
output = input.gsub(/(?:\{)([\p{Alpha}][^\}]+?)(?:(?<=[0-9])\})/, '[\1]')
#this converts to @authorYear pandoc format
output.gsub!(/([\p{Alpha}][\p{Alnum}\s-]+)(?:,\s)(\d{4})(?:\s#\d+)/) { | str | str = "@" + $1.tr(' ', '').downcase + $2 }
#this combines adjacent pandoc refs together
output.gsub!(/\]\[@(?=\p{Alpha})/) { | str | str = "; @" }

puts output
