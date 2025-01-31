--[[
	The purpose of this filter is to take ordered and bulleted lists and add 
	custom-styles to the first and subsequent items…
	Version:   1.00
	Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details
]]

local olfirst	= "Numbered 1"
local olrest	= "Numbered"
local blfirst	= "Bulleted 1"
local blrest	= "Bulleted"

function OrderedList(ol)
	local i = 0
	return ol:walk {
		Plain = function (p)
			i = i + 1
			if i == 1 then styleName = olfirst else styleName = olrest end
			return pandoc.Div(pandoc.Para(p.content), {['custom-style'] = styleName})
		end 
	}
end

function BulletList(bl)
	local i = 0
	return bl:walk {
		Plain = function (p)
			i = i + 1
			if i == 1 then styleName = blfirst else styleName = blrest end
			return pandoc.Div(pandoc.Para(p.content), {['custom-style'] = styleName})
		end 
	}
end
