--[[
	convertIndex.lua: convert \index{item} markup for marking up words for an 
	index into ODT, DOCX, Typst & LaTeX native alternatives. You can use \index{Ancestor!Parent!item}
	to mark up an index item with an ancestor, parent and item.
	You can use custom tag \indext{item} to also include the term in the 
	text. This makes writing easier as you can markup words directly.
	For ODT it uses the native XML markup for index items. You need to add the index.
	For Typst, you also need https://typst.app/universe/package/in-dexter
	For LaTeX you need a template that contains the makeindex command in the right place.
	Version:   1.06
	Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details
]]

local function split(inputString, delimiter) -- split a string based on a delimiter
	local list = {}
	for token in string.gmatch(inputString, "[^" .. delimiter .. "]+") do
		table.insert(list, token)
	end
	return list
end

local counter = nil
local function formatIndex(format, key, isterm) --returns a rawinline index entry for tex, odt and typst
	if not counter then counter = 1 end -- counter is used for odt
	local keys = split(key, "!:/") -- split our input for ancestor!parent!item
	local nkeys = 3
	if #keys == 1 then -- if there is only one key
		keys = {"","",keys[1]}
		nkeys = 1
	elseif #keys == 2 then -- if there is only two keys
		keys = {"",keys[1],keys[2]}
		nkeys = 2
	end
	local ukey = keys[3]:gsub("(%w)(%w*)", function(firstChar, rest) return firstChar:upper() .. rest end) -- make term titlecase
	if format:match 'opendocument' then --odt
		if isterm then
			key = '<text:alphabetical-index-mark-start text:id="IMarkX' .. stringify(counter) .. 
			'" text:key1="' .. keys[1] .. '" text:key2="' .. keys[2] .. 
			'"/>' .. keys[3] .. '<text:alphabetical-index-mark-end text:id="IMarkX' .. stringify(counter) .. '"/>'
			counter = counter + 1
		else
			key = '<text:alphabetical-index-mark text:key1="' .. keys[1] .. 
			'" text:key2="' .. keys[2] .. '" text:string-value="' .. keys[3] .. '"/>'
		end
		return pandoc.RawInline(format, key)
	elseif format:match 'openxml' then
		if nkeys == 1 then
			key = ukey
		else
			key = keys[2] .. ':' .. ukey -- openxml only supports one level of hierarchy
		end
		prefix = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText> XE "</w:instrText></w:r><w:r ><w:instrText>'
		suffix = '</w:instrText></w:r><w:r><w:instrText>" </w:instrText></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
		if isterm then
			prefix = '<w:r><w:t>' .. key .. '</w:t></w:r>' .. prefix
		end
		key = prefix .. key .. suffix
		return pandoc.RawInline(format, key)
	elseif format:match 'typst' then -- typst with in-dexter
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
		return pandoc.RawInline(format, key)
	elseif format:match 'latex' then -- latex support for \indext
		key = key:gsub("[:/]", "!") -- replace : or / with !
		if isterm then
			key = keys[3] .. " \\index{" .. key .. "}"
		else
			key = "\\index{" .. key .. "}"
		end
		return pandoc.RawInline(format, key)
	else
		return key
	end
end

function RawInline(r) -- parse rawinlines looking for raw latex \index{key} and \indext{key} to convert
	local fmt = FORMAT
	local isterm = false -- default to not use terms
	if fmt:match("odt") then fmt = "opendocument" end
	if fmt:match("docx") then fmt = "openxml" end
	kw = r.text
	if string.match("tex", r.format) and kw:match("\\index") then
		if kw:match("\\indext{") then
			kw = kw:match("\\indext{(.-)}")
			isterm = true
		else
			kw = kw:match("\\index{(.-)}")
		end
		if string.len(kw) > 0 then return formatIndex(fmt, kw, isterm) end
	end
end
