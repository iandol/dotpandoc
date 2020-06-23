#!/usr/bin/env ruby
# add today's date to metadata

require 'paru/filter'
require 'date'

Paru::Filter.run do 
  metadata["date"] = "#{Date.today.to_s}"
  stop!
end
