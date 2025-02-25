--[[
pagebreak – convert raw LaTeX page breaks to other formats

Copyright © 2017-2023 Benct Philip Jonsson, Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]
local stringify = (require 'pandoc.utils').stringify

--- configs – these are populated in the Meta filter.
local default_pagebreaks = {
  asciidoc = '<<<\n\n',
  context = '\\page',
  epub = '<p style="page-break-after: always;"> </p>',
  html = '<div style="page-break-after: always;"></div>',
  latex = '\\newpage{}',
  ms = '.bp',
  ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
  odt = '<text:p text:style-name="Pagebreak"/>',
  typst = '#pagebreak(weak: true)\n\n'
}

local function pagebreak_from_config (config)
  local pagebreak = default_pagebreaks
  local html_class = config['html-class']
    and stringify(config['html-class'])
    or os.getenv 'PANDOC_PAGEBREAK_HTML_CLASS'
  if html_class and html_class ~= '' then
    pagebreak.html = string.format('<div class="%s"></div>', html_class)
  end

  local odt_style = config['odt-style']
    and stringify(config['odt-style'])
    or os.getenv 'PANDOC_PAGEBREAK_ODT_STYLE'
  if odt_style and odt_style ~= '' then
    pagebreak.odt = string.format('<text:p text:style-name="%s"/>', odt_style)
  end

  return pagebreak
end

--- Return a block element causing a page break in the given format.
local function newpage(format, pagebreak)
  if format:match 'asciidoc' then
    return pandoc.RawBlock('asciidoc', pagebreak.asciidoc)
  elseif format == 'context' then
    return pandoc.RawBlock('context', pagebreak.context)
  elseif format == 'docx' then
    return pandoc.RawBlock('openxml', pagebreak.ooxml)
  elseif format:match 'epub' then
    return pandoc.RawBlock('html', pagebreak.epub)
  elseif format:match 'html.*' then
    return pandoc.RawBlock('html', pagebreak.html)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', pagebreak.latex)
  elseif format:match 'ms' then
    return pandoc.RawBlock('ms', pagebreak.ms)
  elseif format:match 'odt' then
    return pandoc.RawBlock('opendocument', pagebreak.odt)
  elseif format:match 'typst' then
    return pandoc.RawBlock('typst', pagebreak.typst)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

--- Checks whether the given string contains a LaTeX pagebreak or
--- newpage command.
local function is_newpage_command(command)
  return command:match '^\\newpage%{?%}?$'
    or command:match '^\\pagebreak%{?%}?$'
end

-- Returns a filter function for RawBlock elements, checking for LaTeX
-- pagebreak/newpage commands; returns `nil` when the target format is
-- LaTeX.
local function latex_pagebreak (pagebreak)
  -- Don't do anything if the output is TeX
  if FORMAT:match 'tex$' then
    return nil
  end
  return function (el)
    -- check that the block is TeX or LaTeX and contains only
    -- \newpage or \pagebreak.
    if el.format:match 'tex' and is_newpage_command(el.text) then
      -- use format-specific pagebreak marker. FORMAT is set by pandoc to
      -- the targeted output format.
      return pagebreak
    end
    -- otherwise, leave the block unchanged
    return nil
  end
end

--- Checks if a paragraph contains nothing but a form feed character.
local formfeed_check = function (para)
  return #para.content == 1 and para.content[1].text == '\f'
end

--- Checks if a paragraph looks like a LaTeX newpage command.
local function plaintext_check (para)
  return #para.content == 1 and is_newpage_command(para.content[1].text)
end

--- Replaces a paragraph with a pagebreak if on of the `checks` returns true.
local function para_pagebreak(raw_pagebreak, checks)
  local is_pb = function (para)
    return checks:find_if(function (pred) return pred(para) end)
  end
  return function (para)
    if is_pb(para) then
      return raw_pagebreak
    end
  end
end

--- Filter function; this is the entrypoint when used as a filter.
function Pandoc (doc)
  local config = doc.meta.pagebreak or {}
  local break_on = config['break-on'] or {}
  local raw_pagebreak = newpage(FORMAT, pagebreak_from_config(doc.meta))
  local paragraph_checks = pandoc.List{}
  if break_on['form-feed'] then
    paragraph_checks:insert(formfeed_check)
  end
  if break_on['plaintext-command'] then
    paragraph_checks:insert(plaintext_check)
  end
  return doc:walk {
    RawBlock = latex_pagebreak(raw_pagebreak),
    -- Replace paragraphs that contain just a form feed char.
    Para = #paragraph_checks > 0
      and para_pagebreak(raw_pagebreak, paragraph_checks)
      or nil
  }
end