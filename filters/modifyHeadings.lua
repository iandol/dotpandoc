-- for plain text make Headings stand out a bit

function Header(el)
	if el.level == 1 then
		Strs = pandoc.walk_block(el, {
			Str = function(el)
				 return pandoc.SmallCaps(el.text)
			end })
		Strs.content:extend{pandoc.Str('\n===============')}
		return Strs
	elseif el.level == 2 then
		el.content:extend{pandoc.Str('\n---------------')}
		return el
	else
		el.content:extend{pandoc.Str('\n- - - - - - - -')}
		return el
	end
end

function Strong(elem)
	return pandoc.SmallCaps(elem.content)
end