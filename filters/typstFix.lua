--[[
	typstFix.lua: typst fix filter for pandoc 
	Version:   1.05
	Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details

	Usage: Solves some problems for Typst output from Pandoc:
	(1) Typst uses <label> syntax for #ids, which is not compatible with the
	Raw HTML extension. We take advantage of Raw HTML extension to convert
	<...> to a typst RawInline. (2) The second problem is that Typst uses @fig-
	and @tbl- to refer to figures and tables, which is not compatible with
	the use of @ for Pandoc citations. So we check if the ref starts with
	fig- or tbl- and convert it to a typst RawInline. (3) [this is now fixed] 
	Finally, Pandoc injects a physical width into Images, causing them to 
	overflow the page margins, if no width has been set, we set it to 100%.
]]

-- convert raw html to raw typst as typst uses <label> for #IDs
function RawInline(r)
	if not FORMAT:match('typst') then return end
	if string.match(r.format, "html") then
		return pandoc.RawInline("typst", r.text)
	end
end

-- convert Typst crossreferences like @fig-one to RawInlines
-- everything else stays a bibliographic citation
function Cite(cite)
	if not FORMAT:match('typst') then return end
	local c = cite.citations[1].id
	if string.match(c, "^fig%-") or
	string.match(c, "^tbl%-") or
	string.match(c, "^eq%-") or
	string.match(c, "^lst%-") or 
	string.match(c, "^sec%-") then
		c = "@" .. c
		return pandoc.RawInline("typst", c)
	end
end

-- make sure images without width attribute have a 100% width
-- see https://github.com/jgm/pandoc/issues/9236
-- now fixed V0.11.0 of Typst + Pandoc v3.1.12.3, so not needed
-- function Image(im)
-- 	local env = pandoc.system.environment()
-- 	local var = env["FIGWIDTH"] -- possible override with ENV
-- 	if not var or var == "" then
-- 		newwidth = "100%"
-- 	else
-- 		newwidth = var
-- 	end
-- 	if not im.attributes.width then
-- 		im.attributes.width = newwidth
-- 		return im
-- 	end
-- end

