#!/usr/bin/env ruby
# This regularises author:, affiliation: and institute: metadata fields
# into a standardised structure that is better parsed by my Pandoc templates.
# It generates correspondence_list and equal_contribution fields if present in
# the author list.
# ---
# author:
#   - name: Joanna Doe
#     afilliation: [1,2]
#     correspondence: jdoe@example.ac.cn
#     equal_contributor: true
# institute:
#   - 1: Institute of Cool
#   - 2: Centre for Assimilation
# ...
#
# You should be able to use several different input styles, including strings
# like 'Joanna Doe^1,2^' and lists without specifying the name: subfield
#
# VERSION: 1.0.0

require 'paru/filter'

def authorSuperscript(input)
	cp = input.match(/\s?\^([\w\d\s\,§‡¶†\*]+)\^/)
	if cp.nil?
		Hash['name' => input]
	else
		Hash['name' => cp.pre_match, 'affiliation' => [cp[1]]]
	end
end

def instituteSuperscript(inst, index = 1)
	cp = inst.match(/^\s?\^([\w\d]+)\^\s?/)
	if cp.nil?
		Hash['index' => index.to_s, 'name' => inst]
	else
		Hash['index' => cp[1], 'name' => cp.post_match.strip]
	end
end

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

def fixAffiliations(author)
	return author unless author.key?('affiliation')
	if author['affiliation'].is_a?(String)
		list = author['affiliation'].chomp.split(',')
		newList = Array.new(list.length, String)
		list.each_with_index do |item, i|
			newList[i] = item
		end
	elsif author['affiliation'].is_a?(Integer)
		newList = [author['affiliation']]
	elsif author['affiliation'].is_a?(Array)
		newList = author['affiliation']
	end
	author['affiliation'] = newList
	return author
end

Paru::Filter.run do
	stop! unless metadata.key?('author') || metadata.key?('institute')
	newAuthor = nil
	newInst = nil
	correspondenceList = []
	equalContributors = false
	#============Standardise author fields
	authors = metadata['author']
	authors = [Hash['name' => authors]] if authors.is_a?(String)
	if authors.is_a?(Array)
		newAuthor = Array.new(authors.length, {})
		authors.each_with_index do |au, i|
			if au.is_a?(String) # just an array of strings, turn to array of hashes
				au = authorSuperscript(au)
				newAuthor[i] = fixName(au)
			elsif au.is_a?(Hash)
				newAuthor[i] = fixName(au)
			end

			newAuthor[i] = fixAffiliations(newAuthor[i])

			newAuthor[i]['correspondence'] = newAuthor[i]['email'] if newAuthor[i].key?('email')
			if newAuthor[i].key?('correspondence')
				correspondenceList.push(newAuthor[i]['name'] + ' <' + newAuthor[i]['correspondence'] + '>')
			end

			if newAuthor[i].key?('equal_contributor')
				equalContributors = true
			end
		end
	end
	#============Standardise institute fields
	inst = metadata['institute']
	inst = [Hash['index' => 1, 'name' => inst]] if inst.is_a?(String)
	if inst.is_a?(Array)
		inst.each_with_index do |mi, i|
			if mi.is_a?(String)
				inst[i] = instituteSuperscript(mi, i)
			elsif mi.is_a?(Array) && mi.length == 2
				inst[i] = Hash('index' => mi[0].to_s, 'name' => mi[1].to_s)
			elsif mi.is_a?(Hash) && mi.keys.length == 1
				inst[i] = Hash('index' => mi.keys[0].to_s, 'name' => mi.values[0].to_s)
			end
		end
		newInst = inst
	end
	#============Write our new fields
	metadata['author'] = newAuthor unless newAuthor.nil?
	metadata['institute'] = newInst unless newInst.nil?
	metadata['correspondence_list'] = correspondenceList unless correspondenceList.empty?
	metadata['equal_contributors'] = true if equalContributors == true
	# just in case a template uses tags instead of keywords
	metadata['tags'] = metadata['keywords'] if metadata['keywords']
	# tell paru no more processing needed!
	stop!
end
