#!/usr/bin/env ruby
# If we have keywords: metadata, convert it to an
# "Keywords" paragraph at the start of the document
# This is because Word template cannot handle this natively
#
# VERSION: 1.0.0

require 'paru/filter'

Paru::Filter.run do
  stop! unless metadata.key?('keywords')
  kw = metadata['keywords']
  text = '**Keywords**: '
  if kw.is_a?(String)
    text += kw
  elsif kw.is_a?(Array)
    kw.each_index do |i|
      text += kw[i].to_s + ', '
    end
    text = text[0..-3]
  elsif kw[0].is_a?(Hash)
    text = 'HASH TODO'
  end
  p = Paru::PandocFilter::Para.new([])
  p.inner_markdown = text
  document.prepend(p)
  stop!
end