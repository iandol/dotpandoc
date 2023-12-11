--[[
	typstFix.lua: typst fix filter for pandoc 
	Version:   1.01 
	Copyright: (c) 2023 Ian Max Andolina License=MIT, see LICENSE for details

	Usage: Typst uses <label> syntax for #ids, which is not compatible with
	Raw HTML extension. We take advantage of Raw HTML extension to convert
	<...> to a typst RawInline. The second problem is that Typst uses @fig-
	and @tbl- to refer to figures and tables, which is not compatible with
	the use of @ for Pandoc citations. So we check if the ref starts with
	fig- or tbl- and convert it to a typst RawInline. Finally, Pandoc
	injects a physical width into Images, causing them to overflow the page
	margins, if no width has been set, we set it to 100%.
]]

--convert raw html to raw typst: typst uses <label> for #ID
function RawInline(r)
	if string.match(r.format, "html") then
		return pandoc.RawInline("typst", r.text)
	end
end

-- convert Typst crossreferences to RawInlines
function Cite(cite)
	c = cite.content[1].text
	if string.match(c, "@fig%-") or
	string.match(c, "@tbl%-") or
	string.match(c, "@eq%-") or
	string.match(c, "@lst%-") or 
	string.match(c, "@sec%-") then
		return pandoc.RawInline("typst", c)
	end
end

-- make sure images have a 100% width if not specified
function Image(im)
	local env = pandoc.system.environment()
	local var = env["FIGWIDTH"] -- possible override with ENV
	if not var or var == "" then
		newwidth = "100%"
	else
		newwidth = var
	end
	if not im.attributes.width then
		im.attributes.width = newwidth
		return im
	end
end

