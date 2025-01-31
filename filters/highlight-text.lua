--[[
# MIT License
#
# Copyright (c) 2024 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

local function highlight_html(span, colour, bg_colour)
  if span.attributes['style'] == nil then
    span.attributes['style'] = ''
  elseif span.attributes['style']:sub(-1) ~= ";" then
    span.attributes['style'] = span.attributes['style'] .. ";"
  end

  if colour ~= nil then
    span.attributes['colour'] = nil
    span.attributes['color'] = nil
    span.attributes['style'] = span.attributes['style'] .. 'color: ' .. colour .. ';'
  end

  if bg_colour ~= nil then
    span.attributes['bg-colour'] = nil
    span.attributes['bg-color'] = nil
    span.attributes['style'] = span.attributes['style'] .. 'background-color: ' .. bg_colour .. ';'
  end

  return span
end

local function highlight_latex(span, colour, bg_colour)
  if colour == nil then
    colour_open = ''
    colour_close = ''
  else
    colour_open = '\\textcolor[HTML]{' .. colour:gsub("^#", "") .. '}{'
    colour_close = '}'
  end
  if bg_colour == nil then
    bg_colour_open = ''
    bg_colour_close = ''
  else
    bg_colour_open = '\\colorbox[HTML]{' .. bg_colour:gsub("^#", "") .. '}{'
    bg_colour_close = '}'
  end

  table.insert(
    span.content, 1,
    pandoc.RawInline('latex', colour_open .. bg_colour_open)
  )
  table.insert(span.content, pandoc.RawInline('latex', bg_colour_close .. colour_close))

  return span.content
end

local function highlight_openxml_docx(span, colour, bg_colour)
  local spec = '<w:r><w:rPr>'
  if bg_colour ~= nil then
    spec = spec .. '<w:shd w:val="clear" w:fill="' .. bg_colour:gsub("^#", "") .. '"/>'
  end
  if colour ~= nil then
    spec = spec .. '<w:color w:val="' .. colour:gsub("^#", "") .. '"/>'
  end
  spec = spec .. '</w:rPr><w:t>'

  table.insert(span.content, 1, pandoc.RawInline('openxml', spec))
  table.insert(span.content, pandoc.RawInline('openxml', '</w:t></w:r>'))

  return span.content
end

local function highlight_openxml_pptx(span, colour, bg_colour)
  local spec = '<a:r><a:rPr dirty="0">'
  if bg_colour ~= nil then
    spec = spec .. '<a:highlight><a:srgbClr val="' .. bg_colour:gsub("^#", "") .. '" /></a:highlight>'
  end
  if colour ~= nil then
    spec = spec .. '<a:solidFill><a:srgbClr val="' .. colour:gsub("^#", "") .. '" /></a:solidFill>'
  end
  spec = spec .. '</a:rPr><a:t>'

  -- table.insert(span.content, 1, pandoc.RawInline('openxml', spec))
  -- table.insert(span.content, pandoc.RawInline('openxml', '</a:t></a:r>'))

  local span_content_string = ""
  for i, inline in ipairs(span.content) do
    span_content_string = span_content_string .. pandoc.utils.stringify(inline)
  end

  return pandoc.RawInline('openxml', spec .. span_content_string .. '</a:t></a:r>')
end

local function highlight_typst(span, colour, bg_colour)
  if colour == nil then
    colour_open = ''
    colour_close = ''
  else
    colour_open = '#text(rgb("' .. colour .. '"))['
    colour_close = ']'
  end

  if bg_colour == nil then
    bg_colour_open = ''
    bg_colour_close = ''
  else
    bg_colour_open = '#highlight(fill: rgb("' .. bg_colour .. '"))['
    bg_colour_close = ']'
  end

  table.insert(
    span.content, 1,
    pandoc.RawInline('typst', colour_open .. bg_colour_open)
  )
  table.insert(
    span.content,
    pandoc.RawInline('typst', bg_colour_close .. colour_close)
  )

  return span.content
end

function Span(span)
  local colour = span.attributes['colour']
  if colour == nil then
    colour = span.attributes['color']
  end

  local bg_colour = span.attributes['bg-colour']
  if bg_colour == nil then
    bg_colour = span.attributes['bg-color']
  end

  if colour == nil and bg_colour == nil then return span end

  if FORMAT:match 'html' or FORMAT:match 'revealjs' then
    return highlight_html(span, colour, bg_colour)
  elseif FORMAT:match 'latex' or FORMAT:match 'beamer' then
    return highlight_latex(span, colour, bg_colour)
  elseif FORMAT:match 'docx' then
    return highlight_openxml_docx(span, colour, bg_colour)
  elseif FORMAT:match 'pptx' then
    return highlight_openxml_pptx(span, colour, bg_colour)
  elseif FORMAT:match 'typst' then
    return highlight_typst(span, colour, bg_colour)
  else
    return span
  end
end
