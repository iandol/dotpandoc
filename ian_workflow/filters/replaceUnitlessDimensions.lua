-- if image dimensions without any units, assume points

function Image(im)
	if im.attributes.width then
		if im.attributes.width:match "^%d+$" then
			im.attributes.width = '' .. im.attributes.width .. 'pt'
		end
	end
	if im.attributes.height then
		if im.attributes.height:match "^%d+$" then
			im.attributes.height = '' .. im.attributes.height .. 'pt'
		end
	end
	return im
end