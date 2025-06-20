--[[
This takes fenced div OR gfm alert syntax and converts it for typst / plain / ODT / DOCX / ICML / HTML
Alert types: note, tip, important, warning, caution
For Typst, install https://typst.app/universe/package/gentle-clues/

> [!tip]
> GFM Alert.
> Some **Tip content**.
> More content: H~2~O.

> [!warning] A Custom title
> GFM Alert with custom title.
>
> My **warning** content.
> Some *more* content.

:::note
Fenced Div. 

Some note content. 
More *content*.
:::

::: {.important title="Custom Title"}
Some content.
:::

Version:   0.12
Copyright: (c) 2025 Ian Max Andolina License=MIT, see LICENSE for details
]]

stringify = pandoc.utils.stringify
pdType = pandoc.utils.type

local alerts = pandoc.List({'note', 'tip', 'important', 'warning', 'caution'})
local preIcon = pandoc.List({"💡","🔦","🤚","🚨","❗"})
local gentleClues = pandoc.List{'abstract', 'info', 'question', 'memo', 'task', 
	'tip', 'success', 'warning', 'error', 'example'}

-- Convert the given string to title case using gsub
--
-- @param input string
-- @return string
local function titleCase(input)
	return input:gsub("(%w)(%w*)",function(firstChar, rest) return pandoc.text.upper(firstChar) .. rest end)
end

-- Check if the given value is a pandoc.List or pandoc.Inlines.
--
-- @param input item
-- @return true / false
local function isPandocList(input)
	return pdType(input) == 'List' or pdType(input) == 'Inlines'
end

-- Inject alert Title text into the content
--
-- @param content the content of the alert
-- @param alert the alert name
-- @param customTitle the [optional] custom title
-- @return modified content
local function injectTitle(content, alert, customTitle)
	local _,alertidx = alerts:find(alert)
	if not alerts:includes(alert) then alert,alertidx = alerts[1],1 end
	if isPandocList(customTitle) then customTitle = stringify(customTitle) end
	if customTitle == "" then customTitle = nil end
  
	local thisTitle = preIcon[alertidx] .. " " .. (customTitle or titleCase(alert))
	
	if isPandocList(content) then
		content:insert(1, pandoc.Str(thisTitle))
		content:insert(2, pandoc.LineBreak())
	end
	return content
end

-- Create the gentle clues prefix from the alert name and optional custom title
--
-- @param alert the alert name
-- @param customTitle the [optional] custom title
-- @return the prefix string
local function createTypstPrefix(alert, customTitle)
	local adjustedAlert = alert
	local adjustedTitle = titleCase(alert)
	if alert == 'note' then
		adjustedAlert = 'info'
	elseif alert == 'important' then
		adjustedAlert = 'memo'
	elseif alert == 'caution' then
		adjustedAlert = 'warning'
	elseif not gentleClues:includes(alert) then
		adjustedAlert = 'example'
	end
	if customTitle then
		return "\n\n#" .. adjustedAlert .. '(title: "' .. stringify(customTitle) .. '")['
	elseif alert ~= adjustedAlert then
		return "\n\n#" .. adjustedAlert .. '(title: "' .. adjustedTitle .. '")['
	else
		return "\n\n#" .. adjustedAlert .. '['
	end
end

-- Creates an attribute with a class and a custom style
--
-- @param alert the alert name
-- @return the attributes table
local function addClassAndStyle(alert)
	return pandoc.Attr({class = alert,['custom-style'] = titleCase(alert)})
end

-- Converts alert to a Typst Raw block
--
-- @param content the content of the alert
-- @param alert the alert name
-- @param customTitle the [optional] custom title
-- @return the wrapped content
local function wrapTypst(content, alert, customTitle)
	local prefix = createTypstPrefix(alert, customTitle)
	local rawcontent = pandoc.write(pandoc.Pandoc(content),'typst'):gsub("\n$","")
	return pandoc.RawBlock('typst', prefix .. rawcontent .. "]\n\n")
end

-- Wraps the content of a Plain alert in a Div with line breaks and custom style
--
-- @param content the content of the alert
-- @param alert the alert name
-- @return the wrapped content
local function wrapPlain(content, alert)
	content[1].content:insert(1, pandoc.LineBreak()) -- Insert line break at the start
	content[1].content:insert(1, pandoc.Str('----------------------------------')) -- Insert separator line
	content[#content].content:insert(pandoc.LineBreak()) -- Insert line break at the end
	content[#content].content:insert(pandoc.Str('----------------------------------')) -- Insert separator line
	return pandoc.Div(content, addClassAndStyle(alert)) -- Add class and style to the Div
end

-- Wraps the content of an alert in a Div with custom style
--
-- @param content the content of the alert
-- @param alert the alert name
-- @return the wrapped content
local function wrapOther(content, alert)
	return pandoc.Div(content, addClassAndStyle(alert))
end

--=======================================================================
--=======================================================================Filter functions
--=======================================================================

-- Pandoc converts GFM alerts to classed Divs, and fenced divs with the same class also get processed here
function Div(d)
	local alert = d.classes[1]
	local customTitle = d.attributes['title']
	if not alerts:includes(alert) then return end
	
	if d.content[1].classes and d.content[1].classes:includes('title') then
		d.content:remove(1) -- remove title paragraph to give us more flexibility
	end
	
	if not FORMAT:match 'typst' then
		d.content[1].content = injectTitle(d.content[1].content, alert, customTitle) -- add our alert title inline to the content
	end
	
	if FORMAT:match('typst') then
		return wrapTypst(d.content, alert, customTitle)
	elseif FORMAT:match('plain') then
		return wrapPlain(d.content, alert)
	else
		return wrapOther(d.content, alert)
	end
end

-- GFM alerts with a custom title are emitted as blockquotes so they must be caught here
function BlockQuote(bq)
	local firstBlock = bq.content[1].content
	local alert = pandoc.text.lower(string.match(stringify(firstBlock[1]),"^%[%!(%a+)%]%s?"))
	if alert == nil then return end
	local customTitle = pandoc.List()
	local newContent = pandoc.List()
	
	for j = 2, #firstBlock do
		if firstBlock[j].tag == "SoftBreak" then break end
		customTitle:insert(firstBlock[j])
	end
	for j = #customTitle+2, #firstBlock do
		newContent:insert(firstBlock[j])
	end
	if #customTitle > 0 and customTitle[1].tag == "Space" then customTitle:remove(1) end
	if #newContent > 0 and newContent[1].tag == "SoftBreak" then newContent:remove(1) end

	if not FORMAT:match 'typst' then
		newContent = injectTitle(newContent, alert, stringify(customTitle)) -- add our alert title inline to the content
	end
	
	local content = bq.content:clone()
	content[1] = pandoc.Para(newContent)
	
	if FORMAT:match('typst') then
		return wrapTypst(content, alert, customTitle)
	elseif FORMAT:match('plain') then
		return wrapPlain(content, alert)
	else
		return wrapOther(content, alert)
	end
end
