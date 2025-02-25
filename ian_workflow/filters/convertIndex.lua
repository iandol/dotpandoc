--[[
	convertIndex.lua: parse \index{item} for marking up words for an index
	for ODT, DOCX, Typst & LaTeX native output. 
	
	You can use \index{Ancestor:Parent:item} to mark up an index item with
	an ancestor, parent and item. {note: DOCX only supports Parent:item}

	You can use a cross-reference: \index{item|see{term1, term2}}

	For ODT and TYPST you can make a main index entry page number (bolded) 
	by using a leading asterisk: \index{*item}.
	
	You can use a custom tag \indext{item} to include the term itself in the
	text. This makes writing easier as you can markup words directly. For
	example "This falls \indext{here}." will become "This falls
	here#index[Here]." for Typst output. Note \indext{} is not compatible
	with |see{} cross-references...
	
	For ODT or DOCX it uses the native XML markup for index items.
	
	For Typst, you'll need https://typst.app/universe/package/in-dexter 
	
	For LaTeX you need a template that contains the makeindex command in the
	right place.

	Version:   1.20
	Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details
]]
---@diagnostic disable: undefined-global

---Makes sure users know if their pandoc version is too old for this
---filter.
PANDOC_VERSION:must_be_at_least '2.17'

---do we Title case the words that go into the index?
local doTitleCase = true

---split a string based on a delimiter
---@param inputString string
---@param delimiter string
---@return table
local function split(inputString, delimiter)
	local list = {}
	for token in string.gmatch(inputString, "[^" .. delimiter .. "]+") do
		table.insert(list, token)
	end
	return list
end

---Replace |see{term} with " \t "See: term in the given string
---@param input string
---@return string
local function replaceSeeClause(input)
	return input:gsub("|see{(.-)}", ", see—%1")
end

---Remove |see{term} in the given string
---@param input string
---@return unknown
local function removeSeeClause(input)
	return input:gsub("|see{(.-)}", "")
end

---Title case the given string
---@param input string
---@return string
local function titleCase(input)
	return input:gsub("(%w)(%w*)", function(firstChar, rest) return firstChar:upper() .. rest end) 
end

-- Parse the \index{...} and \indext{...} tags
---comment
---@param tag table
---@return string
---@return boolean
---@return boolean
local function parseIndexTag(tag)
	local isTerm = false -- default to not use terms
	local isMain = false -- default to not use main index
	indexItem = tag.text
	if string.match("tex", tag.format) and indexItem:match("^\\index") then
		if indexItem:match("^\\indext{") then -- check if it's a term+index entry
			indexItem = indexItem:match("^\\indext{(.*)}$")
			isTerm = true
		else -- it is a normal index entry
			indexItem = indexItem:match("^\\index{(.*)}$")
		end
		if indexItem:match("^%*") then -- a leading * means it's a main index
			indexItem = indexItem:sub(2,-1)
			isMain = true
		end
	else
		indexItem = ""
	end
	return indexItem, isTerm, isMain
end

---returns the format, note if it is docx or odt we need to use 
---openxml and opendocument respectively
---@return string
local function getFormat()
	fmt = FORMAT
	if FORMAT:match("odt") then fmt = "opendocument" end
	if FORMAT:match("docx") then fmt = "openxml" end
	return fmt
end

local counter = nil
---returns a formatted index entry for tex, odt, docx and typst
---@param format string
---@param item string
---@param isTerm boolean
---@param isMain boolean
---@param isInline boolean
---@return any
local function formatIndex(format, item, isTerm, isMain, isInline)
	if not counter then counter = 1 end -- counter is used for odt

	---split our input for ancestor!parent!item
	local keys = split(item, "!:/") 
	if #keys == 1 then -- if there is only an item
		keys = {"","",keys[1]}
		nkeys = 1
	elseif #keys == 2 then -- if there is only parent and item
		keys = {"",keys[1],keys[2]}
		nkeys = 2
	else -- two ancestors and an item
		keys = {keys[1],keys[2],keys[3]}
		nkeys = 3
	end

	---process the items
	local tcItem = keys[3]
	keys[3] = removeSeeClause(keys[3])
	tcItem = replaceSeeClause(tcItem) -- deal with |see{term} in the item
	if doTitleCase then
		keys[1] = titleCase(keys[1])
		keys[2] = titleCase(keys[2])
		tcItem = titleCase(tcItem) -- use title case for the index
		tcItem = tcItem:gsub('See','see') -- lowercase See
	end

	---ODT
	if format:match 'opendocument' then
		if isMain then main = 'text:main-entry="true" ' else main = '' end
		local kfrag = ''
		if nkeys == 2 then
			kfrag = 'text:key1="' .. keys[2] .. '" '
		elseif nkeys == 3 then
			kfrag = 'text:key1="' .. keys[1] .. '" text:key2="' .. keys[2] .. '" '
		end
		if isTerm then
			item = '<text:alphabetical-index-mark-start ' .. main .. 'text:id="IMarkX' .. tostring(counter) .. '" ' ..
			kfrag .. '/>' .. 
			keys[3] .. '<text:alphabetical-index-mark-end text:id="IMarkX' .. tostring(counter) .. '"/>'
			counter = counter + 1
		else
			item = '<text:alphabetical-index-mark ' .. main .. kfrag .. 'text:string-value="' .. tcItem .. '"/>'
		end
		if isInline then
			return pandoc.RawInline(format, item)
		else
			return pandoc.Para(pandoc.RawInline(format, item))
		end

	---DOCX
	elseif format:match 'openxml' then
		if nkeys == 1 then
			item = tcItem
		elseif nkeys == 2 then
			item = keys[2] .. ':' .. tcItem
		elseif nkeys == 3 then 
			item = keys[1] .. ':' .. keys[2] .. ':' .. tcItem
		end
		prefix = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText> XE "</w:instrText></w:r><w:r ><w:instrText>'
		suffix = '</w:instrText></w:r><w:r><w:instrText>" </w:instrText></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
		if isTerm then
			prefix = '<w:r><w:t>' .. keys[3] .. '</w:t></w:r>' .. prefix
		end
		item = prefix .. item .. suffix
		if isInline then
			return pandoc.RawInline(format, item)
		else
			return pandoc.Para(pandoc.RawInline(format, item))
		end

	---TYPST
	elseif format:match 'typst' then -- typst with in-dexter
		tcItem = tcItem:gsub(':','')
		if isMain then prefix = '#index-main' else prefix = '#index' end
		if nkeys == 1 then
			item = prefix .. '[' .. tcItem .. ']'
		elseif nkeys == 2 then
			item = prefix .. '("' .. keys[2] .. '", "' .. tcItem .. '")'
		else
			item = prefix .. '("' .. keys[1] .. '", "' .. keys[2] .. '", "' .. tcItem .. '")'
		end
		if isTerm then
			item = keys[3] .. item
		end
		if isInline then
			return pandoc.RawInline(format, item)
		else
			return pandoc.Para(pandoc.RawInline(format, item))
		end

	---LATEX
	elseif format:match 'latex' then -- latex support
		item = item:gsub("[:/]", "!") -- replace : or / with !
		if isMain then item = item .. '|texmf' end
		if isTerm then
			item = keys[3] .. "\\index{" .. item .. "}"
		else
			item = "\\index{" .. item .. "}"
		end
		if isInline then
			return pandoc.RawInline(format, item)
		else
			return pandoc.Para(pandoc.RawInline(format, item))
		end

	---OTHERS
	else
		if isInline and isTerm then
			return keys[3] -- return item
		elseif not isInline and not isTerm then
			return pandoc.Para(keys[3]) -- return item wrapped in paragraph
		else
			return ""
		end
	end
end

-- Pandoc filter parses rawinlines looking for 
-- raw latex \index{key} and \indext{key} to convert
function RawInline(r)
	if not string.match("tex", r.format) then return end
	local isInline = true -- we come from a raw inline
	fmt = getFormat()
	local indexItem, isTerm, isMain = parseIndexTag(r)
	if string.len(indexItem) > 0 then 
		return formatIndex(fmt, indexItem, isTerm, isMain, isInline)
	end
end

-- Pandoc filter parses rawblocks looking for 
-- raw latex \index{key} and \indext{key} to convert
function RawBlock(r)
	if not string.match("tex", r.format) then return end
	local isInline = false -- we are not a raw inline
	fmt = getFormat()
	local indexItem, isTerm, isMain = parseIndexTag(r)
	if string.len(indexItem) > 0 then 
		return formatIndex(fmt, indexItem, isTerm, isMain, isInline)
	end
end

