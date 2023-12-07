--[[
	typstFix.lua: typst fix filter for pandoc Version:     1.00 Copyright:
	(c) 2023 Ian max Andolina License:     MIT - see LICENSE file for
	details

	Usage: Typst uses <label> syntax for #ids, which is not compatible with
	Raw HTML extension. We still take advantage of Raw HTML extension to
	convert <...> to a RawInline, where we change the format to raw typst.
	The second problem is that Typst uses @fig- and @tbl- to refer to
	figures and tables, which is not compatible with the use of @ for Pandoc
	citations. So we check if the ref starts with fig- or tbl- and convert
	it to a typst RawInline. Finally, Pandoc injects a physical width into
	Images, causing them to overflow the page margins, if no width has been
	set we set it to 100%.
]]

--local logging = require 'logging' -- for development only
--function Pandoc(pandoc)
--	logging.temp('pandoc', pandoc)
--end

function Image(im)
	if im.attributes.width == nil then
		im.attributes.width = "100%"
	end
	return im
end

function RawInline(r)
	--convert html to typst format as typst uses <label>
	if string.match(r.format, "html") then
		return pandoc.RawInline("typst", r.text)
	end
end

function Cite(cite)
	c = cite.content[1].text
	if string.match(c, "@fig%-") or
	string.match(c, "@tbl%-") or
	string.match(c, "@eq%-") or
	string.match(c, "@lst%-") or 
	string.match(c, "@sec%-") then
		-- convert the crossref to a RawInline
		return pandoc.RawInline("typst", c)
	end
end

