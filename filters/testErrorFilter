#!/usr/bin/env ruby
# this is designed fail and cause a pandoc error, useful for testing only
require "paru/filter"
Paru::Filter.run do 
    with "Emph" do |e|
        e.append(Paru::PandocFilter::Para.new([]))
    end
end