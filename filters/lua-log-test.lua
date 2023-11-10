--	need to set path for logging.lua to be found: 
--		set-env LUA-PATH $E:HOME"/.local/share/pandoc/filters/?.lua;;"

local logging = require 'logging'

function Pandoc(pandoc)
	logging.temp('pandoc', pandoc)
end