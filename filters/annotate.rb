#!/usr/bin/env ruby
# Annotate custom blocks: example blocks and important blocks
require "paru/filter"

example_count = 0

Paru::Filter.run do
  
  with "Div.example > Header" do |header|
    if header.level == 3 
        example_count += 1
        header.inner_markdown = "Example #{example_count}: #{header.inner_markdown}"
    end
  end

  with "Div.important" do |d|
    d.inner_markdown = d.inner_markdown + "\n\n*(important)*"
  end
end
