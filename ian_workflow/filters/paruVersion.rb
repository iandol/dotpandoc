#!/usr/bin/env ruby
# A filter to insert paru's version. All occurrences of 
# '::paru::version' are replaced by paru's version.
#
# VERSION: 1.0.0

require "paru"
require "paru/filter"

def version(str)
  str.gsub "::paru::version", Paru::VERSION.join(".")
end

Paru::Filter.run do 
  
  with "Str" do |str|
    str.string = version(str.string)
  end

  with "CodeBlock" do |code|
    code.string = version(code.string)
  end

  with "Link" do |link|
    link.target.url = version(link.target.url)
    link.target.title = version(link.target.title)
  end

end
