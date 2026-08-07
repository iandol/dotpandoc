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
local FORMAT = FORMAT or 'markdown'

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
function ReferenceMap:new (opts)
  opts = opts or {}
  local refmap = {
    references = {},
    counters = {},
    -- Numbering mode: "1" = plain sequential numbers (default), "1.1" =
    -- numbers prefixed with the current Heading 1, reset on every new one.
    numbering = opts.numbering or '1',
    -- The number of the current level-1 section, and the per-section
    -- counters of figures/tables/equations (used only in "1.1" mode).
    -- `section_number` must stay a present field: the metatable pattern
    -- used by ReferenceMap makes missing-field access raise a
    -- "'__index' chain too long" error.
    section_number = false,
    local_counts = {},
  }
  return setmetatable(refmap, self)
end

function ReferenceMap:count(reftype, level)
  if level then
    -- Hierarchical section numbering.
    self.counters[reftype] =
      (self.counters[reftype] or SectionCounter()):increase(level)
  elseif self.numbering == '1.1' then
    -- Number within the current Heading 1 section, e.g. "2.1".
    self.local_counts[reftype] = (self.local_counts[reftype] or 0) + 1
    self.counters[reftype] =
      (self.section_number or 0) .. '.' .. self.local_counts[reftype]
  else
    self.counters[reftype] = (self.counters[reftype] or 0) + 1
  end
  return self.counters[reftype]
end

--- Add a new element to the reference map
function ReferenceMap:add(reftype, id, linktext)
  -- Create a reference object if the ID is a non-empty string
  if type(id) == 'string' and id ~= '' then
    local counter = self.counters[reftype]
    linktext = linktext or pandoc.Inlines{tostring(counter)}

    -- Sections are numbered hierarchically via a SectionCounter; snapshot
    -- its display string so later headers don't change earlier references.
    local number = type(counter) == 'table' and tostring(counter) or counter

    self.references['#' .. id] = {
      ['number'] = number,
      ['content'] = linktext,
      ['ref-type'] = reftypes[reftype],
      ['type'] = reftype,
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
      -- On each new Heading 1, reset the per-section counters and remember
      -- the current section number for "1.1" numbering mode.
      if self.numbering == '1.1' and h.level == 1 then
        self.local_counts = {}
        self.section_number =
          tostring(self.counters['section'] or ''):match('^(%d+)') or false
      end
    end,
    Span = function (span)
      if span.identifier and span.classes:includes(equation_class) then
        local eqnum = self:count('equation')
        self:add('equation', span.identifier)
        span.attributes.number = eqnum and tostring(eqnum) or nil
        return span, false
      end
    end,
    Math = function (mth)
      local before, label, after = mth.text:match '^(.+)\\label%{([^%}]+)%}(.*)$'
      if before and label then
        local formula = before .. (after or '')
        local eqnum = self:count('equation')
        self:add('equation', label)
        mth.text = formula:gsub('%s*$', ''):gsub('%s\n', '\n') -- trim lines
        local attr = {
          id = label,
          class = equation_class,
          number = eqnum and tostring(eqnum) or nil
        }
        return pandoc.Span(mth, attr), false
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

local function make_label (refnum, name, sep)
  local num = refnum and refnum.content or pandoc.Inlines('?')

  return pandoc.Span(
    pandoc.Inlines(name) .. {Space} .. num .. sep,
    {class="caption-label"}
  )
end

--- Add a label to a referenceable element.
local function add_label (refnums, opts)
  return function (element)
    local elementname = opts.name[element.t:lower()]
    assert(elementname, "Don't know how to make a label for " .. element.t)

    local refnum = refnums['#' .. element.identifier]
    local label = make_label(refnum, elementname, opts.separator)
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
  -- Checks whether the given attributes mark an element as ignored.
  local is_ignored = function (attr)
    return attr.attributes['querverweis-ignore']
      or attr.classes:includes('querverweis-ignore')
  end

  -- Returns a filter to format the link text.
  local format_label_text = function (refobj)
    -- Sections carry a string snapshot (e.g. "1.1.2"); all other reference
    -- types carry a plain number.
    local number = refobj.number
    return {
      Str = function (str)
        if type(number) == 'number' then
          str.text = str.text:format(number)
        else
          str.text = str.text:gsub('%%%a', number or '')
        end
        return str
      end
    }
  end

  -- Prefix a default cross-reference with the name of the referenced element
  -- type (e.g. "Fig."), if requested via the `link-labels` option.
  local with_link_label = function (refobj, content)
    local linkname = (opts['link-names'] or opts.name)[refobj.type]
    if opts['link-labels'] and linkname then
      return pandoc.Inlines(linkname) .. {Space} .. content
    end
    return content
  end

  return {
    Table = opts.labels and add_label(refnums, opts) or nil,
    Figure = opts.labels and add_label(refnums, opts) or nil,

    Link = function (link)
      if not is_ignored(link.attr) then
        local refobj = refnums[link.target]
        if refobj then
          link.attributes['ref-type'] = opts['ref-types']
            and refobj['ref-type']
            or nil
          if next(link.content) then
            link.content = link.content:walk(format_label_text(refobj))
          else
            -- Use default content if the link was empty
            link.content = with_link_label(refobj, refobj.content)
          end
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
          local content = with_link_label(refobj, refobj.content)
          refs:insert(pandoc.Link(content, target, '', attributes))
        end
      end
      return next(refs) and refs or cite
    end
  }
end

--- Set of default caption options.
local default_element_names = {
  ['figure'] = 'Figure',
  ['table'] = 'Table',
}

--- Set of default options.
local default_options = {
  ['name']            = default_element_names,
  ['id-from-caption'] = true,
  ['labels']          = false,
  ['link-labels']     = false,
  ['link-names']      = false,
  ['numbering']       = '1',
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
    elseif key == 'labels' or key == 'link-labels' then
      local labelsconf = useropts[key]
      if ptype(labelsconf) == 'List' then
        opts[key] = labelsconf:map(stringify):includes(FORMAT)
      else
        opts[key] = not not labelsconf  -- ensure boolean
      end
    elseif key == 'numbering' then
      opts[key] = stringify(useropts[key] or value)
    else
      opts[key] = useropts[key] or value
    end
  end

  return opts
end

return {{
    Pandoc = function (doc)
      local useropts = {}

      -- Options from the `querverweis` metadata block (YAML map).
      local qvmeta = doc.meta.querverweis
      if qvmeta and ptype(qvmeta) == 'table' then
        for k, v in pairs(qvmeta) do useropts[k] = v end
      end

      -- Also accept flat `-M querverweis.<key>=<value>` command-line
      -- metadata, which pandoc exposes as dotted keys rather than a nested
      -- map (e.g. -M querverweis.link-labels=true,
      --      -M querverweis.link-names.figure=Fig.).
      local prefix = 'querverweis.'
      for key, value in pairs(doc.meta) do
        if type(key) == 'string' and key:sub(1, #prefix) == prefix then
          local path = key:sub(#prefix + 1)
          local cur = useropts
          local parts = {}
          for part in path:gmatch('[^.]+') do parts[#parts + 1] = part end
          for i = 1, #parts - 1 do
            cur[parts[i]] = cur[parts[i]] or {}
            cur = cur[parts[i]]
          end
          cur[parts[#parts]] = value
        end
      end

      doc.meta.querverweis = nil
      local opts = make_opts(useropts)
      local refmap = ReferenceMap(opts)

      doc = refmap:fill(doc)
      return doc:walk(set_labels(refmap.references, opts))
    end
}}
