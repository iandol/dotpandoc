#!/usr/bin/env ruby
# remove horizontal rules

require "paru/filter"

Paru::Filter.run do
  with "HorizontalRule" do |rule|
    if rule.has_parent? then
      rule.parent.delete(rule)
    end
  end
end
