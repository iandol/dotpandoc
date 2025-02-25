--[[
# Lua Filter REPL Test

You can remote debug Pandoc Lua filters using [Zerobrane
Studio](https://studio.zerobrane.com) The debugger requires luasocket and
mobdebug, both are bundled in Zerobrane, or you can use your Lua installed
versions. 

## Without Lua Installed:
If you don't have Lua installed on your system, should update the
environment search path to use mobdebug.lua and luasocket from Zerobrane's
install location. See
[documentation](https://studio.zerobrane.com/doc-remote-debugging) for
details. For e.g. macOS this would be for zsh:

    export ZBS=/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio 
    export LUA_PATH="./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"  
    export LUA_CPATH="$ZBS/bin/?.dylib;$ZBS/bin/clibs53/?.dylib;$ZBS/bin/clibs53/?/?.dylib"

Elvish: 

    set-env ZBS /Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio
    set-env LUA_PATH "./?.lua;"$E:ZBS"/lualibs/?/?.lua;"$E:ZBS"/lualibs/?.lua"
    set-env LUA_CPATH $E:ZBS"/bin/?.dylib;"$E:ZBS"/bin/clibs54/?.dylib;"$E:ZBS"/bin/clibs54/?/?.dylib"

## With Lua installed:
If you have installed Lua v5.4 and added mobdebug + luasocket using luarocks
then they should be available in the default path locations (at least for
POSIX systems), and you shouldn't need to set any path variables.

## How to Trigger the Debugger:

1) Ensure the filter.lua file is opened in the Zerobrane editor; Project >
Start Debugger Server is turned ON; and editor.autoactivate = true is
enabled in your user.lua settings file.

2) Then run pandoc from terminal with the filter that is open in the editor:

    > pandoc --lua-filter luatest.lua Here is a *test* for **REPL**
    debugging. [ctrl]+[d]

3) Zerobrane's debugger will activate. Use the Stack window and Remote
console to examine the environment and execute Lua commands while stepping
through the code.

## Commandline Use:
With mobdebug and luasocket installed, you can also debug from your teminal
without running an IDE:

> pandoc-lua -e "require('mobdebug').listen()"

But Zerobrane offers richer functionality…

## VS Code Alterative:

https://github.com/EmmyLua/VSCode-EmmyLua -- it injects a precompiled
library. Inject the library loading code using command palette, then use
dbg.waitIDE() to pause, and dbg.breakHere() to break. Run code BEFORE debugger.

https://github.com/moteus/vscode-mobdebug -- need to use `luarocks install
vscode-mobdebug` and then `require("vscode-mobdebug")`, you may need to
`luarocks remove --force mobdebug`

LuaPanda is another option https://github.com/Tencent/LuaHelper 

]]

lg = require("logging")
md = require("mobdebug")
md.logging = true

--package.cpath = package.cpath .. ";/Users/ian/.vscode/extensions/tangzx.emmylua-0.8.20-darwin-arm64/debugger/emmy/mac/arm64/emmy_core.dylib"
--local dbg = require("emmy_core")
--dbg.tcpListen("localhost", 9966)
--dbg.waitIDE()

function OrderedList(l)
	md.start() --breakpoint
	--dbg.breakHere()
	i = 0
	ll = l:walk {
		Plain = function (p)
			i = i + 1
			if i == 1 then
				d = pandoc.Div(p, {['custom-style'] = 'Numbered 1'})
			else
				d = pandoc.Div(p, {['custom-style'] = 'Numbered'})
			end
			return d
		end 
	}
	return ll
end

function Div(d)
	--md.start()
	dbg.breakHere()
	return d
end

function Meta(m)
	md.start() --breakpoint
	--dbg.breakHere()
	return m
end

function Cite(elem)
	md.start() --breakpoint
	--dbg.breakHere()
	return elem
end

function Emph(elem)
	md.start() --breakpoint
	--dbg.breakHere()
	return elem.content
end

function Strong(elem)
	md.start() --breakpoint
	--dbg.breakHere()
	return pandoc.SmallCaps(elem.content)
end

function Note(elem)
	md.start() --breakpoint
	--dbg.breakHere()
	return elem
end