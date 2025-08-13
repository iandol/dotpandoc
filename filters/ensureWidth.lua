-- if no width set, images > 600px sized to 100% width

function Image(im)
	local sizes = nil
	local mediatype, content = pandoc.mediabag.fetch(im.src)
	if mediatype and mediatype:match("^image/") then
		sizes = pandoc.image.size(content)
	end

	if sizes and sizes.width > 600 and not im.attributes.width then
		im.attributes.width = "100%"
		im.attributes.height = nil
	end
	return im
end