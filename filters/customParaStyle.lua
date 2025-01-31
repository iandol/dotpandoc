--takes all paragraphs and wraps them in a styled div
function Para(blk)
   local attr = pandoc.Attr()
   attr.attributes["custom-style"] = "My Style"
   return pandoc.Div({blk}, attr)
end