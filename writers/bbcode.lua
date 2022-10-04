--[[ ******************************************************************************
     *                                                                            *
     *                         Pandoc 2 BBCode for phpBB                          *
     *                                                                            *
     ******************************************************************************
     "bbcode.lua" v1.2 (2017-05-24)
     adapted by Tristano Ajmone (@tajmone):
     -- https://github.com/tajmone/2bbcode
     ------------------------------------------------------------------------------
     This code was forked by Tristano Ajmone from @lilydjwg's `2bbcode.lua`:

     -- https://github.com/lilydjwg/2bbcode

     Copyright (c) 2016, @lilydjwg (依云), all rights reserved.
     Released under BSD 3-Clause License:

     -- https://github.com/lilydjwg/2bbcode/blob/master/LICENSE

     ==============================================================================
                                  BSD 3-Clause License                             
     ==============================================================================
     Copyright (c) 2016, 依云
     All rights reserved.
     
     Redistribution and use in source and binary forms, with or without
     modification, are permitted provided that the following conditions are met:
     
     * Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer.
     
     * Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.
     
     * Neither the name of the copyright holder nor the names of its
       contributors may be used to endorse or promote products derived from
       this software without specific prior written permission.
     
     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
     AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
     IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
     FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
     DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
     SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
     OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
     OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     ==============================================================================]]
-- Invoke with: pandoc -t bbcode.lua

-- text module from pandoc
text = require 'text'

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body, title, date are strings; authors is an array of strings;
-- variables is a table.  One could use some kind of templating
-- system here; this just gives you a simple standalone HTML file.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add(body)
  if #notes > 0 then
    add('\n\n========Footnotes========\n')
    for _,note in pairs(notes) do
      add(note)
    end
  end
  return table.concat(buffer,'\n') .. '\n'
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return s
end

function Space()
  return " "
end

function SoftBreak()
  return "\n"
end

function LineBreak()
  return "\n"
end

-- CHANGES BY @tajmone: Emphasis
--   *  Convert to Italic [i] instead of Emphasis [em]
function Emph(s)
  return "[i]" .. s .. "[/i]"
end

function Strong(s)
  return "[b]" .. s .. "[/b]"
end

function Subscript(s)
  return '~' .. s .. '~'
end

function Superscript(s)
  return '^' .. s .. '^'
end

function SmallCaps(s)
  return text.upper(s)
end

-- CHANGES BY @tajmone: Strikeout
--   *  Convert to Underline [u] instead of Strikeout/Strikethrough [del]
function Strikeout(s)
  return '[u][color=#CCCCCC]' .. s .. '[/color][/u]'
end

function Link(s, src, tit)
  local ret = '[url'
  if s then
    ret = ret .. '=' .. src
  else
    s = src
  end
  ret = ret .. "]" .. s .. "[/url]"
  return ret
end

function Image(s, src, tit, attr)
  return "[img=" .. tit .. "]" .. src .. "[/img]"
end

-- CHANGES BY @tajmone: Inline Code
--   *  Convert to bold and red.
-- [background=#EEE][font=menlo,consolas,monospace] but many forums don't support it :-(
function Code(s, attr)
  return "[color=#BF2700][b]" .. s .. "[/b][/color]"
end

function InlineMath(s)
  return "\\(" .. s .. "\\)"
end

function DisplayMath(s)
  return "\\[" .. s .. "\\]"
end

function Note(s)
  local num = #notes + 1
  -- add a list item with the note to the note table.
  table.insert(notes, '[' .. num .. ']: ' .. s)
  -- return the footnote reference, linked to the note.
  return '[' .. num .. ']'
end

function Span(s, attr)
  return s
end

function RawInline(format, str)
    return '<<' .. str .. '>>'
end

function Cite(s, cs)
  return "[color=#555555]" .. s .. "[/color]"
end

function Plain(s)
  return s
end

function Para(s)
  return s
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  if lev == 1 then
    return "[size=200][color=#BF2700][b]" .. s .. "[/b][/color][/size]"
  elseif lev == 2 then
    return "[size=175][color=#AF1700][b]" .. s .. "[/b][/color][/size]"
  elseif lev == 3 then
    return "[size=150][color=#9F1700][b]" .. s .. "[/b][/color][/size]"
  elseif lev == 4 then
    return "[size=125][color=#8F0700][b]" .. s .. "[/b][/color][/size]"
  elseif lev == 5 then
    return "[size=110][color=#7F0000][b]" .. s .. "[/b][/color][/size]"
  else
    return "[size=100][b]" .. s .. "[/b][/size]"
  end
end

function BlockQuote(s)
  return "[quote]\n" .. s .. "\n[/quote]"
end

function HorizontalRule()
  return "--------------------------------------------------------------------------------"
end

function LineBlock(ls)
  return table.concat(ls, '\n')
end

function CodeBlock(s, attr)
  return "[code]\n" .. s .. '\n[/code]'
end

function BulletList(items)
  local buffer = {}
  for _, item in ipairs(items) do
    table.insert(buffer, "[*]" .. item)
  end
  return "[list]\n" .. table.concat(buffer, "\n") .. "\n[/list]"
end

function OrderedList(items)
  local buffer = {}
  for _, item in ipairs(items) do
    table.insert(buffer, "[*]" .. item)
  end
  return "[list=1]\n" .. table.concat(buffer, "\n") .. "\n[/list]"
end

-- Revisit association list STackValue instance.
function DefinitionList(items)
  local buffer = {}
  for _, item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer, "[b]" .. k .. "[/b]:\n" ..
                        table.concat(v, "\n"))
    end
  end
  return table.concat(buffer, "\n")
end

-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
function html_align(align)
  if align == 'AlignLeft' then
    return 'left'
  elseif align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
  end
end

-- CHANGES BY @tajmone: CaptionedImage
--   *  Added CaptionedImage function (missing in original)
--        Caused error for GFM images with Alt text (even if Alt was empty)
function CaptionedImage(src, tit, caption, attr)
  return "[img]" .. src .. "[/img]\n[b]" .. caption .. '[/b]\n'
end

-- CHANGES BY @tajmone: Table
--   *  Now presence of a Table in input doesn't throw an error and abort,
--        it just returns empty string, suppressing the table in converted output!
--   *  Warning is printed to STDERR showing the omitted Table's headers
--      (so user can understand what was left out).

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local tmpstr = '| '
  for i, h in pairs(headers) do
    tmpstr = tmpstr .. h .. ' | '
  end
  PrintWarning('Table omitted: ' .. tmpstr)
  return ''
--  error("Table isn't supported")
end

-- CHANGES BY @tajmone: RawBlock
--   *  Suppress from output if it's raw HTML
--      (Even html comments were converted to [code], and Markdown TOC-tags would show up in final BBCode)
--   *  Warning is printed to STDERR with suppresed HTML
function RawBlock(format, str)
  if format == "html" then
    PrintWarning('Raw HTML omitted: ' .. str)
  return ''
  else
    return '[code]\n' .. str .. '\n[/code]\n'
  end
end


function Div(s, attr)
  return s .. '\n'
end

-- CHANGES BY @tajmone: DoubleQuoted
--   *  Added DoubleQuoted function (missing in original)
--      Caused error for text within double quotes
--   *  Returns text in nice UTF-8 curly double quotes (always)
function DoubleQuoted(s)
  return "“" .. s .. '”'
end

-- CHANGES BY @tajmone: SingleQuoted
--   *  Added SingleQuoted function (missing in original)
--      Caused error for text within single quotes
--   *  Returns text in nice UTF-8 curly single quotes (always)
function SingleQuoted(s)
  return "‘" .. s .. '’'
end

-- CHANGES BY @tajmone: PrintWarning function
--   *  I've added this function to warn the user (on STDERR) when
--      some BBCode-unsupported input is suppressed from output.
function PrintWarning(s)
  io.stderr:write("WARNING! " .. s .. '\n')
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
--[[
Let's [test]{.smallcaps} some **stuff here**. What about $e=mc^2$ and more?

```
some code
```

here is a ref: [@hobson2014b] to test


==============================================================================
                                 FILE HISTORY                                 
==============================================================================
v1.2 - 2017-05-24
     - @snan added support for starting lines with pipes to preserve line breaks:
       - function LineBlock(ls)
v1.1 - 2016/12/20
     - Bug Fix: Added missing fucntions:
       - DoubleQuoted()
       - SingleQuoted()
       - SoftBreak()
v1.0 - 2016/12/10
     - Forked from `2bbcode.lua` and created 1st release.
]]
