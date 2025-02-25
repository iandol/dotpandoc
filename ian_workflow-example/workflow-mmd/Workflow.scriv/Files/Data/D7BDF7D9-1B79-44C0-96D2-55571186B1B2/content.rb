#!/usr/bin/env ruby
# If we have author: metadata, convert it to an
# "Authors" and Affiliations" paragraph at the start of the document
# This is because plain text template etc. cannot handle this natively
#
# VERSION: 1.0.0

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

Paru::Filter.run do
  stop! unless metadata.key?('author')
  authors = metadata['author']
  authors = [Hash['name' => authors]] if authors.is_a?(String)
  text = '**Authors**: '
  addContribution = false
  if authors.is_a?(Array)
    authors.each_with_index do |au,i|
      au = fixName(au)
      text += au['name'].to_s
      #--------------------parse affiliation
      if au.key?('affiliation')
        if au['affiliation'].is_a?(String) || au['affiliation'].is_a?(Integer)
          aff = au['affiliation'].to_s
          frag = ''
          a = aff.split(',') # comma seperated values
          a.each do |af|
            if af.match(/^\d+$/)
              frag += '^' + af + '^ '
            else
              frag += af + ''
            end
            text += frag + ' '
          end
        elsif au['affiliation'].is_a?(Array)
          frag = ''
          au['affiliation'].each do |af|
            if af.to_s.match(/^\d+$/)
              frag += '^' + af.to_s + '^ '
            else
              frag += af.to_s
            end
          end
          text += frag[0..-2]
        end
      end
      #----------------parse correspondence
      if au.key?('correspondence') || au.key?('email')
        if au.key?('email')
          text += ' <' + au['email'].to_s + '>'
        else
          text += ' <' + au['correspondence'].to_s + '>'
        end
      end
      #-----------------parse contributions
      if au.key?('equal_contributor')
        text += '†'
        addContribution = true
      end
      text += '  &  '
    end
    text = text[0..-6]
  end
  stop! if text.length < 14

  if addContribution
    p = Paru::PandocFilter::Para.new([])
    p.inner_markdown = "† equal contribution"
    document.prepend(p)
  end
  p = Paru::PandocFilter::Para.new([])
  p.inner_markdown = text
  document.prepend(p)

  stop!
end
