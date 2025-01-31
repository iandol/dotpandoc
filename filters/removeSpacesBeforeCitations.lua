-- see https://github.com/jgm/pandoc/blob/master/doc/lua-filters.md#remove-spaces-before-citations
--➜ pandoc -t native
--This is a test [@jdoe2008] and @jdoe2008 said this.
--[Para [Str "This",Space,Str "is",Space,Str "a",Space,Str "test",Space,Cite [Citation {citationId = "jdoe2008", citationPrefix = [], citationSuffix = [], citationMode = NormalCitation, citationNoteNum = 0, citationHash = 0}] [Str "[@jdoe2008]"],Space,Str "and",Space,Cite [Citation {citationId = "jdoe2008", citationPrefix = [], citationSuffix = [], citationMode = AuthorInText, citationNoteNum = 0, citationHash = 0}] [Str "@jdoe2008"],Space,Str "said",Space,Str "this."]]

local function is_space_before_author_in_text(spc, cite)
  return spc and spc.t == 'Space'
  and cite and cite.t == 'Cite'
  -- there must be only a single citation, and it must have
  -- mode 'AuthorInText'
  --and #cite.citations == 1
  --and cite.citations[1].mode == 'NormalCitation'
end
  
function Inlines (inlines)
  -- Go from end to start to avoid problems with shifting indices.
  require("mobdebug").start()
  for i = #inlines-1, 1, -1 do
    if is_space_before_author_in_text(inlines[i], inlines[i+1]) then
      inlines:remove(i)
    end
  end
  return inlines
end