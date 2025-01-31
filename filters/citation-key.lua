--[[
When converting from DOCX with embedded Zotero refs, BetterBibTeX keys are
never used for the id of the reference. This filter checks if a citation-key
is present and if so replaces the id in the references YAML metadata and
also the citation key used in the text. If there is no citation-key, because
Zotero IDs are not legible for humans, it generates one based on the
author+year plus first four digits of the Zotero ID
Verison: 0.1
Copyright: (c) 2024 Ian Max Andolina License=MIT, see LICENSE for details
]]

local ids = {} -- map of Zotero IDs to citation key

function Cite(c)
	for i,v in ipairs(c.citations) do
		id = v["id"]
		if ids[id] ~= nil then
			c.citations[i]["id"] = ids[id]
		end
	end
	return c
end

function Meta(m)
	if m.references then
		for i,ref in ipairs(m.references) do
			if ref["author"][1].family ~= nil then
				author = ref["author"][1].family
			elseif ref["author"][1].literal ~= nil then
				author = ref["author"][1].literal
			else
				author = ""
			end
			author = author:gsub(" ", ""):lower()
			if ref["issued"] ~= nil then
				year = ref["issued"]:match("^%d%d%d%d")
			else
				year = ""
			end
			id = ref["id"]
			key = ref["citation-key"]
			ids[id] = id
			if key ~= nil then
				ids[id] = pandoc.utils.stringify(key)
				m.references[i]["id"] = ids[id]
			else
				key = author:lower() .. year .. ":" ..id:sub(1,4)
				ids[id] = pandoc.utils.stringify(key)
				m.references[i]["id"] = ids[id]
				m.references[i]["citation-key"] = ids[id]
			end
		end
	end
	return m
end

return { 
	{ Meta = Meta }, 
	{ Cite = Cite } 
}
