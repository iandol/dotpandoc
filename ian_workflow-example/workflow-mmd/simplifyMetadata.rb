#!/usr/bin/env ruby
# this converts an author metadata field
# author:  [name: ..., affiliation:..., correspondence:...]) into a format
# author: Name^affiliation,correspondence,contribution^ that the Word/ODT templates can handle.
# This is because the Word/ODT templates do not have the flexibility
# the other pandoc output formats do...
#
# VERSION: 1.0.2


require 'paru/filter'
def fixName(author)
	author = Hash['name' => author] if author.is_a?(String)
	unless author.key?('name') # convert first key id to name: key
	if author.values[0].is_a?(Hash)
		values = author.values[0]
		values['id'] = author.keys[0]
		values['name'] = values['id']
		author = values
	else
		author['name'] = 'Unknown'
	end
  end
  author
end

testKey = 'author'
pKey = 'pandocomatic-fileinfo'
nameKey = 'name'
affKey = 'affiliation'
corrKey = 'correspondence'
corrMarker = '\*' # which marker to use, if asterisk you must escape it.
contributionKey = 'equal_contributor'
conMarker = '†'

Paru::Filter.run do
	
	stop! unless metadata.key?(testKey)
	stop! if metadata.key?(pKey) && !metadata[pKey]['to'].match(/docx|odt/)
	newAuthor = nil
	correspondence = nil
	contribution = nil
	text = ''
	authors = metadata[testKey]
	authors = [Hash['name' => authors]] if authors.is_a?(String)
	if authors.is_a?(Array)
		newAuthor = Array.new(authors.length)
		authors.each_with_index do |aut, i|
			aut = fixName(aut)
			if aut.key?(nameKey)
				newAuthor[i] = aut[nameKey].to_s
				if aut.key?(affKey)
					if aut[affKey].is_a?(String) || aut[affKey].is_a?(Integer)
						aff = aut[affKey].to_s
						frag = ''
						a = aff.split(',') # comma seperated values
						a.each do |af|
							if af.match(/^\d+$/)
								frag += '^' + af + '^'
							else
								frag += af + ''
							end
							newAuthor[i] += frag + ' '
						end
					elsif aut['affiliation'].is_a?(Array)
						newAuthor[i] += '^'
						aut[affKey].each { |aff| newAuthor[i] += aff.to_s + ',' }
						newAuthor[i] = newAuthor[i][0..-2] + '^'
					end
				end
				if aut.key?(corrKey)
					if newAuthor[i] =~ /\^$/
						newAuthor[i] = newAuthor[i][0..-2] + corrMarker + '^'
					else
						newAuthor[i] += '^' + corrMarker + '^'
					end
					if aut.key?('email')
						email = aut['email']
					else
						email = aut[corrKey]
					end
					if correspondence.nil?
						correspondence = "[#{email}](#{email})"
					else
						correspondence += ' & ' + "[#{email}](#{email})"
					end
				end
				if aut.key?(contributionKey)
					if newAuthor[i] =~ /\^$/
						newAuthor[i] = newAuthor[i][0..-2] + conMarker + '^'
					else
						newAuthor[i] += '^' + conMarker + '^'
					end
					contribution = '† equal contribution'
				end
			end
		end
	elsif authors.is_a?(Hash) # single name: John Doe author
		newAuthor = Array.new(authors.length)
		newAuthor[0] = authors[nameKey]
	end

	metadata[testKey] = newAuthor unless newAuthor.nil?

	unless contribution.nil?
		p = Paru::PandocFilter::Para.new([])
		p.inner_markdown = contribution
		document.prepend(p)
	end
	unless correspondence.nil?
		correspondence = '**' + corrMarker + ' Correspondence**: ' + correspondence + '  \n'
		p = Paru::PandocFilter::Para.new([])
		p.inner_markdown = correspondence
		document.prepend(p)
	end

	stop!
end
