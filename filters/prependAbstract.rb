#!/usr/bin/env ruby
# If we have abstract: metadata, convert it to an
# "Abstract: " paragraph at the start of the document
# This is because some templates / plain text cannot handle this natively
#
# VERSION: 1.0.0

require 'paru/filter'

Paru::Filter.run do
  stop! unless metadata.key?('abstract')
  text = ''
  ab = metadata['abstract']
  if ab.is_a?(String)
    text += ab
  elsif ab.is_a?(Array)
    ab.each_index { |i| text += ab[i].to_s + '. ' }
    text = text[0..-3]
  end
  stop! if text.length == 0
  text = '**Abstract**: ' + text
  p = Paru::PandocFilter::Para.new([])
  p.inner_markdown = text
  document.prepend(p)
  stop!
end