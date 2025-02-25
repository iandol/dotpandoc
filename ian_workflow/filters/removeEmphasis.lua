-- for plain text output remove emph that gets turned to _word_ otherwise, 
-- and make strong become smallcap/uppercase

function Emph(elem)
	return elem.content
end

function Strong(elem)
	return pandoc.SmallCaps(elem.content)
end