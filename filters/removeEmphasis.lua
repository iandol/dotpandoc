-- for plain text output remove emph that gets turned to _word_ otherwise, 
-- and make strong become smallcap/uppercase
--
-- You can remote debug in Lua using Zerobrane Studio, add these to env first
--export ZBS=/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio 
--export LUA_PATH="./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"  
--export LUA_CPATH="$ZBS/bin/?.dylib;$ZBS/bin/clibs53/?.dylib;$ZBS/bin/clibs53/?/?.dylib"
--require("mobdebug").start()

function Emph(elem)
	return elem.content
end

 function Strong(elem)
	return pandoc.SmallCaps(elem.content)
end