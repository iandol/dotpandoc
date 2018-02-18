#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# the job of this preproceccer is to convert criticmarkup to HTML
# which pandoc can parse to e.g. Word output
input = $stdin.read
output = input.gsub(/{~~/, '<del>')
output.gsub!(/~~}/, '</ins>')
output.gsub!(/(?<=\S)~>(?=\S)/, '</del><ins>')
output.gsub!(/\{\+\+/, '<ins>')
output.gsub!(/\+\+\}/, '</ins>')
output.gsub!(/\{--/,   '<del>')
output.gsub!(/--\}/,   '</del>')
output.gsub!(/\{\=\=/, '<mark>')
output.gsub!(/\=\=\}/, '</mark>')
output.gsub!(/\{\>\>/, '<span class="comment" title="')
output.gsub!(/\<\<\}/, '">†</span>')

puts output
