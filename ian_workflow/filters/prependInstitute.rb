#!/usr/bin/env ruby
# If we have institute: metadata, convert it to an
# "Affiliations" paragraph at the start of the document
# This is because Word template cannot handle this natively
#
# VERSION: 1.0.0

require 'paru/filter'

Paru::Filter.run do
  stop! unless metadata.key?('institute')
  inst = metadata['institute']
  text = '**Affiliations**: '
  if inst.is_a?(String)
    text += inst
  elsif inst.is_a?(Array)
    inst.each_with_index do |x,i| 
        if x.is_a?(Hash)
          text += x.keys[0].to_s + ': ' + x.values[0].to_s + ' & ' 
        else
          text += x.to_s + ' & ' 
        end
      end
      text = text[0..-4]
    end
  elsif inst[0].is_a?(Hash)
    text = 'HASH TODO'
  end
  stop! if text.length < 19
  p = Paru::PandocFilter::Para.new([])
  p.inner_markdown = text
  document.prepend(p)
  stop!
end
