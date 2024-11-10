--[[
When converting from DOCX with Zotero refs, the citation keys are not used
for the id. this filter checks if a cistation-key is present and if so
replaces the id and also the citation key used in the text.
]]

lg = require("logging")

local ids = pandoc.List()

function Cite(c)
	for i,v in ipairs(c.citations) do
		id = c.citations[i]["id"]
		if ids[id] ~= nil then
			c.citations[i]["id"] = ids[id]
		end
	end
	return c
end

function Meta(m)
	if m.references then
		for i,_ in ipairs(m.references) do
			id = m.references[i]["id"]
			ids[id] = id
			if m.references[i]["citation-key"] ~= nil then
				ids[id] = pandoc.utils.stringify(m.references[i]["citation-key"])
				m.references[i]["id"] = ids[id]
			else
				m.references[i]["citation-key"] = ids[id]
			end
		end
	end
	return m
end

return {
	{ Meta = Meta },  -- (1)
	{ Cite = Cite }   -- (2)
}
