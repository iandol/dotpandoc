--- querverweis – create and improve cross-references
--
-- Copyright: © 2024 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License: MIT

local pandoc = require 'pandoc'
local List   = require 'pandoc.List'
local utils  = require 'pandoc.utils'

local ptype, stringify = utils.type, utils.stringify

--- The target format of the conversion. This constant should be set by
--- pandoc.
local FORMAT = FORMAT

local equation_class = 'equation'

--- Get the ID of the last span in this block and unwrap the span
local function id_from_block (blk)
  if blk.t == 'Plain' or blk.t == 'Para' then
    local last_inline = blk.content:remove()
    if last_inline and
       last_inline.t == 'Span' and
       last_inline.identifier ~= '' then
      local id = last_inline.identifier
      blk.content:extend(last_inline.content)  -- unwrap the span
      -- drop trailing whitespace
      local elemtype
      for i = #blk.content, 1, -1 do
        elemtype = blk.content[i].t
        if elemtype == 'Space' or elemtype == 'SoftBreak' then
          blk.content[i] = nil
        else
          break
        end
      end
      -- Drop the block if it's now empty
      return id, (next(blk.content) and blk or nil)
    else
      blk.content:insert(last_inline)
      return nil, blk
    end
  end
end

--- Extract the ID from the caption
local function set_id_from_caption (elem)
  local capt = elem.caption.long
  local last_block = capt[#capt]
  if last_block then
    local id
    id, last_block = id_from_block(last_block)
    if id then
      elem.identifier = id
      capt[#capt] = last_block
      elem.caption.long = capt
      return id, elem
    end
  end
  return nil, elem
end

--- Map internal querverweis reference type to JATS 'ref-type'.
local reftypes = {
  ['equation'] = 'disp-formula',
  ['figure']   = 'figure',
  ['section']  = 'sec',
  ['table']    = 'table',
}

--- Class used to count sections, or elements in sections.
local SectionCounter = {}
function SectionCounter:new ()
  return setmetatable({ counters = {} }, self)
end
function SectionCounter:increase (level)
  local counters = self.counters
  for i = 1, level do
    counters[i] = counters[i] or 0
  end
  counters[level] = counters[level] + 1
  for i = level + 1, #counters do
    counters[i] = nil
  end
  return self
end
function SectionCounter:__tostring ()
  return table.concat(self.counters, '.')
end
SectionCounter.__index = SectionCounter
SectionCounter.__call  = SectionCounter.new
setmetatable(SectionCounter, SectionCounter)


--
-- ReferenceMap
--

--- Map from identifiers to elements.
local ReferenceMap = {}

--- Create a new reference map.
function ReferenceMap:new ()
  local refmap = {
    references = {},
    counters = {},
  }
  return setmetatable(refmap, self)
end

function ReferenceMap:count(reftype, level)
  if level then
    self.counters[reftype] =
      (self.counters[reftype] or SectionCounter()):increase(level)
  else
    self.counters[reftype] = (self.counters[reftype] or 0) + 1
  end
end

--- Add a new element to the reference map
function ReferenceMap:add(reftype, id, linktext)
  -- Create a reference object if the ID is a non-empty string
  if type(id) == 'string' and id ~= '' then
    linktext = linktext or pandoc.Inlines{tostring(self.counters[reftype])}

    self.references['#' .. id] = {
      ['content'] = linktext,
      ['ref-type'] = reftypes[reftype]
    }
  end
end

--- Fill the reference map for the given document
function ReferenceMap:fill(doc)
  local function add_captioned_to_reftargets(key, elem)
    self:count(key)
    local id = elem.attr.identifier
    -- If the element has no ID, try to get one from the caption.
    if id == '' then
      id, elem = set_id_from_caption(elem)
      -- use `true` instead of an ID as a placeholder, so numbering
      -- will still work.
      self:add(key, id or true)
      return elem
    else
      self:add(key, id)
    end
  end

  doc = doc:walk {
    traverse = 'topdown',
    Figure = function (fig)
      return add_captioned_to_reftargets('figure', fig)
    end,
    Header = function (h)
      if h.attr.classes:includes 'unnumbered' then
        self:add('section', h.attr.identifier, stringify(h.content))
      else
        self:count('section', h.level)
        self:add('section', h.attr.identifier)
      end
    end,
    Span = function (span)
      if span.identifier and span.classes:includes(equation_class) then
        self:count('equation')
        self:add('equation', span.identifier)
        return span, false
      end
    end,
    Math = function (mth)
      local formula, label = mth.text:match '^(.+)\\label%{(.+)%}%s*$'
      if formula and label then
        self:count('equation')
        self:add('equation', label)
        mth.text = formula:gsub('%s*$', '') -- trim end
        return pandoc.Span(mth, {label, {equation_class}}), false
      end
    end,
    Table = function (tbl)
      return add_captioned_to_reftargets('table', tbl)
    end,
  }

  return doc
end

ReferenceMap.__index = ReferenceMap
ReferenceMap.__call = ReferenceMap.new
setmetatable(ReferenceMap, ReferenceMap)

--- A pandoc Space element. Created once for optimization.
local Space = pandoc.Space()

local function make_label (refnum, conf, sep)
  local num = refnum and refnum.content or pandoc.Inlines('?')

  return pandoc.Span(
    {conf.name, Space} .. num .. sep,
    {class="caption-label"}
  )
end

--- Add a label to a referenceable element.
local function add_label (refnums, opts)
  return function (element)
    local elementconf = opts.caption[element.t:lower()]
    assert(elementconf, "Don't know how to make a label for " .. element.t)

    local refnum = refnums['#' .. element.identifier]
    local label = make_label(refnum, elementconf, opts.separator)
    local cpt = element.caption and element.caption.long
    if label and cpt then
      if cpt[1] and List{'Plain', 'Para'}:includes(cpt[1].t) then
        cpt[1].content = {label} .. cpt[1].content
      else
        cpt:insert(pandoc.Plain(label))
      end
      element.caption.long = cpt
    end
    return element
  end
end

--- Set labels on links, references, figures, and tables.
local function set_labels (refnums, opts)
  return {
    Table = opts.labels and add_label(refnums, opts) or nil,
    Figure = opts.labels and add_label(refnums, opts) or nil,

    Link = function (link)
      if not next (link.content) then
        local refobj = refnums[link.target]
        if refobj then
          link.attributes['ref-type'] = opts['ref-types']
            and refobj['ref-type']
            or nil
          link.content = refobj.content
          return link
        end
      end
    end,

    Cite = function (cite)
      local refs = pandoc.Inlines{}
      for _, citation in ipairs(cite.citations) do
        local target = '#' .. citation.id
        local refobj = refnums[target]
        if refobj then
          local attributes = {
            ['ref-type'] = opts['ref-types'] and refobj['ref-type'] or nil
          }
          refs:insert(pandoc.Link(refobj.content, target, '', attributes))
        end
      end
      return next(refs) and refs or cite
    end
  }
end

--- Set of default caption options.
local default_captions = {
  ['figure'] = {
    name = 'Figure',
  },
  ['table'] = {
    name = 'Table',
  },
}

--- Set of default options.
local default_options = {
  ['caption']         = default_captions,
  ['id-from-caption'] = true,
  ['labels']          = false,
  ['ref-types']       = false,
  ['separator']       = pandoc.Inlines{Space},
}

--- Create querverweis options
local function make_opts (useropts)
  useropts = useropts or {}
  local opts = {}
  for key, value in pairs(default_options) do
    if key == 'separator' then
      opts[key] =
        (useropts.separator == 'colon' and pandoc.Inlines{':', Space}) or
        (useropts.separator == 'period' and pandoc.Inlines{'.', Space}) or
        value
    elseif key == 'labels' then
      local labelsconf = useropts[key]
      if ptype(labelsconf) == 'List' then
        opts[key] = labelsconf:map(stringify):includes(FORMAT)
      else
        opts[key] = not not labelsconf  -- ensure boolean
      end
    else
      opts[key] = useropts[key] or value
    end
  end

  return opts
end

return {{
    Pandoc = function (doc)
      local opts = make_opts(doc.meta.querverweis)
      doc.meta.querverweis = nil
      local refmap = ReferenceMap(opts)

      doc = refmap:fill(doc)
      return doc:walk(set_labels(refmap.references, opts))
    end
}}
