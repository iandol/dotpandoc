-- counts words in a document 
-- use it as: pandoc --lua-filter wordcount.lua input.md

words = 0 

wordcount = { 
  Str = function(el) 
    -- we don't count a word if it's entirely punctuation: 
    if el.text:match("%P") then 
        words = words + 1 
    end 
  end, 

  Code = function(el) 
    _,n = el.text:gsub("%S+","") 
    words = words + n 
  end, 

  CodeBlock = function(el) 
    _,n = el.text:gsub("%S+","") 
    words = words + n 
  end 
} 

function Pandoc(el) 
    -- skip metadata, just count body: 
    pandoc.walk_block(pandoc.Div(el.blocks), wordcount) 
    print("There were " .. words .. " words in body") 
    os.exit(0) 
end 