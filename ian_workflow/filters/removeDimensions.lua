-- if has image dimensions remove them

function Image(im)
	if im.attributes.width then
		im.attributes.width = nil
	end
	if im.attributes.height then
		im.attributes.height = nil
	end
	return im
end