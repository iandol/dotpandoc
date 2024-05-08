--[[
	convertIndex.lua: convert \index{item} markup for marking up words for an 
	index into ODT and Typst native alternatives.
	For ODT it uses the native XML markup for index items.
	For Typst, you also need https://typst.app/universe/package/in-dexter
	Author: Ian Max Andolina
	Version:   1.01
	Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details
]]

local stringify = (require 'pandoc.utils').stringify

local function split(inputString, delimiter)
	local list = {}
	for token in string.gmatch(inputString, "[^" .. delimiter .. "]+") do
		table.insert(list, token)
	end
	return list
end

local counter = nil
local function formatIndex(format, key, isterm) --returns a rawinline index entry for tex, odt and typst
	if not counter then counter = 1 end
	local keys = split(key, "!")
	local nkeys = 3
	if #keys == 1 then
		keys = {"","",keys[1]}
		nkeys = 1
	elseif #keys == 2 then
		keys = {"",keys[1],keys[2]}
		nkeys = 2
	end
	local ukey = keys[3]:gsub("(%w)(%w*)", function(firstChar, rest) return firstChar:upper() .. rest end)
	if format:match 'odt' or format:match 'opendocument' then
		if isterm then
			key = '<text:alphabetical-index-mark-start text:id="00' .. stringify(counter) .. 
			'" text:key1="' .. keys[1] .. '" text:key2="' .. keys[2] .. 
			'"/>' .. keys[3] .. '<text:alphabetical-index-mark-end text:id="00' .. stringify(counter) .. '"/>'
			counter = counter + 1
		else
			key = '<text:alphabetical-index-mark text:key1="' .. keys[1] .. 
			'" text:key2="' .. keys[2] .. '" test:string-value="' .. keys[3] .. '"/>'
		end
		return pandoc.RawInline('opendocument', key)
	elseif format:match 'typst' then
		if nkeys == 1 then
			key = '#index[' .. ukey .. ']'
		elseif nkeys == 2 then
			key = '#index("' .. keys[2] .. '", "' .. ukey .. '")'
		else
			key = '#index("' .. keys[1] .. '", "' .. keys[2] .. '", "' .. ukey .. '")'
		end
		if isterm then
			key = keys[3] .. ' ' .. key
		end
		return pandoc.RawInline('typst', key)
	elseif format:match 'latex' then
		if isterm then
			key = keys[3] .. "\\index{" .. key .. "}"
		else
			key = "\\index{" .. key .. "}"
		end
		return pandoc.RawInline('tex', key)
	else
		return key
	end
end

function RawInline(r) -- parse rawinlines looking for a latex \index{key} and \indexterm{key}to convert
	local fmt = FORMAT
	local isterm = false -- default to not use terms
	if fmt:match("odt") then fmt = "opendocument" end
	kw = stringify(r.text)
	if string.match(r.format, "tex") and kw:match("\\index") and not fmt:match("latex") then
		if kw:match("\\indext{") then
			kw = kw:match("\\indext{(.-)}")
			isterm = true
		else
			kw = kw:match("\\index{(.-)}")
		end
		if string.len(kw) > 0 then return formatIndex(fmt, kw, isterm) end
	end
end
