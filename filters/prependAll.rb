#!/usr/bin/env ruby
# If we have particular metadata, prepend it to a
# paragraph at the start of the document;
# as Word/ODT templates cannot handle this natively
#
# VERSION: 1.0.1

require 'paru/filter'

# here is our list of metadata to convert
prepend_list = {:wordcount => "Wordcount", :comments => "Comments", 
	:keywords => "Keywords", :abstract => "Abstract", :institute => "Affiliations"}

Paru::Filter.run do
	prepend_list.each do |key,val|
		next unless metadata.key?(key.to_s)

		text = ''
		kw = metadata[key.to_s]
		if kw.is_a?(String)
			text += kw
		elsif kw.is_a?(Array)
			kw.each do |x|
				if x.is_a?(Hash)
					text += '^' + x.keys[0].to_s + '^ ' + x.values[0].to_s + '; '
				else
					text += x.to_s + '; '
				end
			end
			text = text[0..-3]
		else
			text = ''
		end
		next if text.empty?

		text = '**' + val + '**: ' + text
		p = Paru::PandocFilter::Para.new([])
		p.inner_markdown = text
		document.prepend(p)
	end
	stop!
end