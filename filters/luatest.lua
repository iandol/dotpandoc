--[[
Lua REPL Test
=============

You can remote debug Pandoc Lua filters using Zerobrane Studio <https://studio.zerobrane.com>
The debugger requires luasocket and mobdebug, both are bundled in Zerobrane. 

Ensure this filter is opened in the Zerobrane editor, Project > Start Debugger Server
is turned ON, and editor.autoactivate = true is enabled in your user.lua settings file.

If you don't have Lua installed on your system you should update the environment 
search path to use mobdebug.lua and luasocket from Zerobrane's install location. 
See <https://studio.zerobrane.com/doc-remote-debugging> for details. For e.g. macOS 
this would be:

export ZBS=/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio 
export LUA_PATH="./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"  
export LUA_CPATH="$ZBS/bin/?.dylib;$ZBS/bin/clibs53/?.dylib;$ZBS/bin/clibs53/?/?.dylib"

If you have installed Lua v5.3 and added mobdebug + luasocket using luarocks then 
they should be available in the default path locations (at least for POSIX systems), 
and you shouldn't need to set any path variables.

Then run pandoc with the filter:

> pandoc --lua-filter luatest.lua 
Here is a *test* for ** REPL ** debugging.
[ctrl]+[d]

And Zerobrane's debugger will activate. Use the Stack window and Remote console
to examine the environment and execute Lua commands.

With mobdebug alone, you can also debug from your teminal:

> lua -e "require('mobdebug').listen()"

But Zerobrane's editor offers nicer functionality.

]]

md = require("mobdebug")
md.start()

function Emph(elem)
	md.pause() --breakpoint
	return elem.content
end

function Strong(elem)
	md.pause() --breakpoint
	return pandoc.SmallCaps(elem.content)
end