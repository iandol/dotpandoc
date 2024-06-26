#!/usr/bin/env ruby
#encoding: utf-8

# This script is used to move pandoc-crossref labels from inside markup,
# which is what Scrivener would generate from it style system, moving the
# labels to the correct places so that pandoc-crossref can find them.
# https://lierdakil.github.io/pandoc-crossref/#image-labels
# This script only corrects figures and equations.

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

text = $stdin.read
text = text.split(/\n/)
labels = []
tags = []
text.each {|line|
	next if line.empty?
	m = line.match(/^!\[(#fig:[^ ]+).+\]\[(.+)\]/)
	if !m.nil?
		labels = labels.push(m[1])
		tags = tags.push(m[2])
		line.gsub!(/#{m[1]}/,'')
	end
	# fix equations
	line.gsub!(/(\{#eq:.+\})(\s+\$\$)\s*$/, '  $$  \1')
}

text = text.join("\n")

labels.each_index {|idx|
	tR = '(\[' + tags[idx] + '\]:.+)\{(.+)\}'
	text.gsub!(/#{tR}/, '\1 {' + labels[idx] + ' \2}')
}

text.gsub!(/\n!\[\s+/, "\n![")

puts text
