--[[
# Lua Filter REPL Test

https://pandoc.org/lua-filters.html#pandoc.cli.repl

Starts a read-eval-print loop (REPL). The function returns all values of the
last evaluated input. Exit the REPL by pressing ctrl-d or ctrl-c; press F1
to get a list of all key bindings.

]]

function Pandoc(doc)
	-- start repl, allow to access the `doc` parameter
	return pandoc.cli.repl{ doc = doc }
end

function Emph(elem)
	return pandoc.cli.repl{ elem = elem }
end

function Strong(elem)
	return pandoc.cli.repl{ elem = elem }
end


