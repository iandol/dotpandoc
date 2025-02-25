-- text-crossrefs.lua
-- https://bastien-dumont.onmypc.net/git/bdumont/pandoc-lua-filters/src/branch/master/text-crossrefs
-- A Pandoc Lua filter that extends Pandoc's cross-referencing abilities
-- with references to any portion of text
-- by its page number, its note number (when applicable)
-- or an arbitrary reference type (with ConTeXt or LaTeX output).
-- Copyright 2024 Bastien Dumont (bastien.dumont [at] posteo.net)
-- This file is under the MIT License: see LICENSE for more details

local stringify = pandoc.utils.stringify

local TEXT_CROSSREF_CLASS = 'tcrf'
local REF_TYPE_ATTR = 'reftype'
local PREFIXED_ATTR = 'prefixref'
local PLACE_LABEL_ATTR = 'refanchor'
local IS_CONFIG_ARRAY = { ['additional_types'] = true }
local RAW_ATTRIBUTE

-- ConTeXt-specific tweak in order to add the label to the footnote
--[[
  Placing the label in square brackets immediatly after \footnote
  in the regular way would require unpacking the content
  of the Note and wrapping them with the RawInlines
  '\footnote[note:' .. label .. ']{' and '}'.
  However, Notes have the strange property of being Inlines
  that contain Blocks, so this would result in Blocks being
  brought into the content of the object that contains the Note,
  which would be invalid.
  That's why we place the label at the end of the \footnote
  and redefine the macro so that it takes it into account.
]]--

local function support_footnote_label_ConTeXt(metadata)
  if RAW_ATTRIBUTE == 'context' then
    local label_macro_def = '\n\\def\\withfirstopt[#1]#2{#2[#1]}\n'
    if not metadata['header-includes'] then
      metadata['header-includes'] = pandoc.MetaBlocks(pandoc.RawBlock('context', ''))
    end
    metadata['header-includes']:insert(pandoc.RawBlock('context', label_macro_def))
  end
  return metadata
end

-- Configuration

local function define_raw_attribute()
  if FORMAT == 'native' then
    RAW_ATTRIBUTE = pandoc.system.environment().TESTED_FORMAT
  elseif FORMAT == 'docx' then
    RAW_ATTRIBUTE = 'openxml'
  elseif FORMAT == 'odt' or FORMAT == 'opendocument' then
    RAW_ATTRIBUTE = 'opendocument'
  elseif FORMAT == 'context' or FORMAT == 'latex' then
    RAW_ATTRIBUTE = FORMAT
  else
    error(FORMAT ..
          ' output not supported by text-crossrefs.lua.')
  end
end

local function define_label_template()
  if RAW_ATTRIBUTE == 'opendocument' or RAW_ATTRIBUTE == 'openxml' then
    IS_LABEL_SET_BY_PANDOC = true
  elseif RAW_ATTRIBUTE == 'context' then
    if PANDOC_VERSION < pandoc.types.Version('2.14') then
      LABEL_TEMPLATE = '\\pagereference[{{label}}]'
    else
      IS_LABEL_SET_BY_PANDOC = true
    end
  elseif RAW_ATTRIBUTE == 'latex' then
    if PANDOC_VERSION < pandoc.types.Version('3.1.7') then
      LABEL_TEMPLATE = '\\label{{{label}}}'
    else
      IS_LABEL_SET_BY_PANDOC = true
    end
  end
end

local config = {
  page_prefix = 'p. ',
  pages_prefix = 'pp. ',
  note_prefix = 'n. ',
  notes_prefix = 'nn. ',
  pagenote_first_type = 'page',
  pagenote_separator = ', ',
  pagenote_at_end = '',
  pagenote_factorize_first_prefix_in_enum = 'no',
  multiple_delimiter = ', ',
  multiple_before_last = ' and ',
  references_range_separator = '>',
  range_separator = '–',
  references_enum_separator = ', ',
  only_explicit_labels = 'false',
  default_reftype = 'page',
  default_prefixref = 'yes',
  filelabel_ref_separator = '::',
  range_delim_crossrefenum = ' to ',
  additional_types = {}
}

local accepted_types = {
  page = true,
  note = true,
  pagenote = true
}

local function format_config_to_openxml()
  local to_format = { 'page_prefix',
                'pages_prefix',
                'note_prefix',
                'notes_prefix',
                'pagenote_separator',
                'pagenote_at_end',
                'range_separator',
                'multiple_delimiter',
                'multiple_before_last' }
  for i = 1, #to_format do
    config[to_format[i]] = '<w:r><w:t xml:space="preserve">' ..
      config[to_format[i]] .. '</w:t></w:r>'
  end
end

local function set_configuration_item_from_metadata(item, metamap)
  metakey = 'tcrf-' .. string.gsub(item, '_', '-')
  if metamap[metakey] then
    if IS_CONFIG_ARRAY[item] then
      -- The metadata values is a list of MetaInlines,
      -- each of them contains a single Str.
      for _, value_metalist in ipairs(metamap[metakey]) do
        table.insert(config[item], value_metalist[1].text)
      end
    else
      -- The metadata value is a single Str in a MetaInlines.
      config[item] = metamap[metakey][1].text
    end
  end
end

local function configure(metadata)
  define_raw_attribute()
  define_label_template()
  for item, _ in pairs(config) do
    set_configuration_item_from_metadata(item, metadata)
  end
  if RAW_ATTRIBUTE == 'openxml' then
    format_config_to_openxml()
  end
  if RAW_ATTRIBUTE == 'context' or RAW_ATTRIBUTE == 'latex' then
    for _, additional_type in ipairs(config.additional_types) do
      accepted_types[additional_type] = true
    end
  end
end

-- End of configuration

-- Preprocessing of identifiers on notes
-- Necessary for those output format where a note can be referred to
-- only via an identifier directly attached to it, not to its content

local spans_to_note_labels = {}
local current_odt_note_index = 0
local is_first_span_in_note = true
local current_note_label
local text_to_note_labels = {}

local function map_span_to_label(span)
  if RAW_ATTRIBUTE == 'opendocument' then
    spans_to_note_labels[span.identifier] = 'ftn' .. current_odt_note_index
  elseif RAW_ATTRIBUTE == 'openxml' or RAW_ATTRIBUTE == 'context' then
    if is_first_span_in_note then
      current_note_label = span.identifier
      is_first_span_in_note = false
    end
    spans_to_note_labels[span.identifier] = current_note_label
  end
end

local function map_spans_to_labels(container)
  for i = 1, #container.content do
    -- The tests must be separate in order to support spans inside spans.
    if container.content[i].t == 'Span'
      and container.content[i].identifier
    then
      map_span_to_label(container.content[i])
    end
    if container.content[i].content then
      map_spans_to_labels(container.content[i])
    end
  end
end

local function map_spans_to_notelabels(note)
  if RAW_ATTRIBUTE == 'context'
    or RAW_ATTRIBUTE == 'opendocument'
    or RAW_ATTRIBUTE == 'openxml'
  then
    is_first_span_in_note = true
    map_spans_to_labels(note)
    current_odt_note_index = current_odt_note_index + 1
  end
end

local function control_label_placement(span)
  local label_placement = span.attributes[PLACE_LABEL_ATTR]
  if label_placement then
    local id = span.identifier
    if label_placement == 'end' then
      span.content:insert(pandoc.Span({}, { id = id }))
      span.identifier = nil
    elseif label_placement == 'both' then
      span.content:insert(1, pandoc.Span({}, { id = id .. '-beg' })) -- for DOCX/ODT
      span.content:insert(pandoc.Span({}, { id = id .. '-end' }))
      span.identifier = nil
    elseif label_placement ~= 'beg' then
      error('Invalid value ' .. label_placement .. ' on attribute ' .. PLACE_LABEL_ATTR .. ': ' ..
            'shoud be “beg” (default), “end” of “both”.')
    end
  end
  return span
end

local function make_label(label)
  -- pandoc.Null() cannot be used here because it is a Block element.
  local label_pandoc_object = pandoc.Str('')
  if not IS_LABEL_SET_BY_PANDOC then
    local label_rawcode = string.gsub(LABEL_TEMPLATE, '{{label}}', label)
    label_pandoc_object = pandoc.RawInline(RAW_ATTRIBUTE, label_rawcode)
  end
  return label_pandoc_object
end

local function labelize_span(span)
  if span.identifier ~= '' then
    local label = span.identifier
    local label_begin = make_label(label, 'begin')
    return { label_begin, span }
  end
end

local current_note_labels = {}

local collect_note_labels = {
  Span = function(span)
    if span.identifier ~= ''
      and (config.only_explicit_labels == 'false' or span.classes:includes('label'))
    then
      table.insert(current_note_labels, span.identifier)
    end
  end
}

local function make_notelabel(pos)
  -- About the strategy followed with ConTeXt,
  -- see above support_footnote_label_ConTeXt.
  local raw_code = ''
  if pos == 'begin' then
    if RAW_ATTRIBUTE == 'openxml' then
      raw_code = string.gsub(
        '<w:bookmarkStart w:id="{{label}}_Note" w:name="{{label}}_Note"/>',
        '{{label}}', current_note_labels[1])
    elseif RAW_ATTRIBUTE == 'context' then
      raw_code = '\\withfirstopt[note:' .. current_note_labels[1] .. ']'
    end
  elseif pos == 'end' then
    if RAW_ATTRIBUTE == 'openxml' then
      raw_code = string.gsub('<w:bookmarkEnd w:id="{{label}}_Note"/>',
                             '{{label}}', current_note_labels[1])
    end
  end
  return pandoc.RawInline(RAW_ATTRIBUTE, raw_code)
end

local function labelize_note(note)
  local labelized_note
  local label_begin = make_notelabel('begin')
  local label_end = make_notelabel('end')
  return { label_begin, note, label_end }
end

local function map_text_to_note_labels(current_note_labels)
  local note_label = 'note:' .. current_note_labels[1]
  for _, text_label in ipairs(current_note_labels) do
    text_to_note_labels[text_label] = note_label
  end
end

function set_notelabels(note)
  current_note_labels = {}
  pandoc.walk_inline(note, collect_note_labels)
  if #current_note_labels > 0 then
    map_text_to_note_labels(current_note_labels)
    return labelize_note(note)
  end
end

-- End of preprocessing of identifiers on notes

-- Gathering of data from the references span

local function new_ref(anchor, end_of_range)
  -- A ref is a string-indexed table containing an "anchor" field
  -- and an optionnal "end_of_range" field.
  -- When "end_of_range" is non-nil, the ref is a range.
  local ref = {}
  ref.anchor = anchor
  ref.end_of_range = end_of_range
  return ref
end

local function is_ref_external(raw_references)
  if string.find(raw_references, config.filelabel_ref_separator, 1, true) then
    return true
  else
    return false
  end
end

local function parse_possible_range(reference)
  -- If reference is a string representing a range,
  -- returns the strings representing the boundaries of the range.
  -- Else, returns the string.
  local range_first, range_second = nil
  local delim_beg, delim_end = string.find(reference,
                                           config.references_range_separator,
                                           1, true)
  if delim_beg then
    range_first = string.sub(reference, 1, delim_beg - 1)
    range_second = string.sub(reference, delim_end + 1)
  end
  return (range_first or reference), range_second
end

local function parse_next_reference(raw_references, beg_of_search)
  -- Returns the ref corresponding to the next reference string
  -- and the index which the parsing should be resumed at.
  local current_ref = false
  local next_ref_beg = nil
  if beg_of_search < #raw_references then
    -- The delimiter can be composed of more than one character.
    local delim_beg, delim_end = string.find(raw_references,
                                                                config.references_enum_separator,
                                                                beg_of_search, true)
    if delim_beg then
      reference = string.sub(raw_references, beg_of_search, delim_beg - 1)
      next_ref_beg = delim_end + 1
    else
      reference = string.sub(raw_references, beg_of_search)
      next_ref_beg = #raw_references
    end
    current_ref = new_ref(parse_possible_range(reference))
  end
  return current_ref, next_ref_beg
end

local function parse_references_enum(raw_references)
  -- raw_refs is a string consisting of a list of single references or ranges.
  -- Returns an array of refs produced by "new_ref" above.
  local parsed_refs = {}
  local current_ref, next_ref_beg = parse_next_reference(raw_references, 1)
  while current_ref do
    table.insert(parsed_refs, current_ref)
    current_ref, next_ref_beg =
      parse_next_reference(raw_references, next_ref_beg)
  end
  return parsed_refs
end

local function error_on_attr(attr_key, attr_value, span_content)
  error('Invalid value "' .. attr_value .. '" for attribute "' .. attr_key ..
          '" in the span with class "' .. TEXT_CROSSREF_CLASS ..
          '" whose content is "' .. stringify(span_content) .. '".')
end

local function get_ref_type(span)
  local ref_type = span.attributes[REF_TYPE_ATTR] or config.default_reftype
  if not accepted_types[ref_type] then
    error_on_attr(REF_TYPE_ATTR, ref_type, span.content)
  end
  return ref_type
end

local function if_prefixed(span)
  local prefixed_attr_value = span.attributes[PREFIXED_ATTR] or config.default_prefixref
  if prefixed_attr_value ~= 'yes' and prefixed_attr_value ~= 'no' then
    error_on_attr(PREFIXED_ATTR, prefixed_attr_value, span.content)
  end
  local is_prefixed = true
  if prefixed_attr_value == 'no' then is_prefixed = false end
  return is_prefixed
end

-- End of gathering of data from the references span

-- Formatting references as raw inlines.

local function make_crossrefenum_first_arg(ref_type)
  local ref_type_is_explicit = ref_type ~= config.default_reftype
  local crossrefenum_first_arg = ''
  if ref_type_is_explicit then
    crossrefenum_first_arg = '[' .. ref_type .. ']'
  end
  return crossrefenum_first_arg
end

local function make_crossrefenum_second_arg(is_prefixed)
  local is_prefixed_is_explicit = is_prefixed ~= (config.default_prefixref == 'yes')
  local crossrefenum_second_arg = ''
  local is_prefixed_string = ''
  if is_prefixed_is_explicit then
    if is_prefixed then
      is_prefixed_string = 'withprefix'
    else
      is_prefixed_string = 'noprefix'
    end
    crossrefenum_second_arg = '[' .. is_prefixed_string .. ']'
  end
  return crossrefenum_second_arg
end

local function make_crossrefenum_references_list(refs, ref_type)
  local crossrefenum_references_list = ''
  for i = 1, #refs do
    local ref = refs[i]
    local anchor = ref.anchor
    if FORMAT == 'context'
      and (ref_type == 'note' or ref_type == 'pagenote')
    then
      anchor = text_to_note_labels[anchor]
    end
    local texified_ref = '{' .. anchor
    if ref.end_of_range then
      texified_ref = texified_ref .. config.range_delim_crossrefenum .. ref.end_of_range
    end
    texified_ref = texified_ref .. '}'
    crossrefenum_references_list = crossrefenum_references_list .. texified_ref
  end
  return crossrefenum_references_list
end

local function make_raw_content_tex(refs, ref_type, is_prefixed)
  local texified_references = ''
  texified_references = '\\crossrefenum'
    .. make_crossrefenum_first_arg(ref_type)
    .. make_crossrefenum_second_arg(is_prefixed)
    .. '{' .. make_crossrefenum_references_list(refs, ref_type) .. '}'
  return texified_references
end

local function make_prefix_xml(ref_type, is_plural)
  local prefix = ''
  if is_plural then
    prefix = config[ref_type .. 's_prefix']
  else
    prefix = config[ref_type .. '_prefix']
  end
  return prefix
end

local function make_page_reference_xml(target, is_prefixed)
  local xml_page_ref = ''
  if is_prefixed then
    xml_page_ref = make_prefix_xml('page', false)
  end
  if RAW_ATTRIBUTE == 'opendocument' then
    xml_page_ref = xml_page_ref ..
      '<text:bookmark-ref ' ..
      ' text:reference-format="page" text:ref-name="' ..
      target .. '">000</text:bookmark-ref>'
  elseif RAW_ATTRIBUTE == 'openxml' then
    xml_page_ref = xml_page_ref ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> PAGEREF ' ..
      target .. ' \\h </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
      '<w:r><w:t>000</w:t></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
  end
  return xml_page_ref
end

local function make_pagerange_reference_xml(first, second, is_prefixed)
  local prefix = ''
  if is_prefixed then prefix = make_prefix_xml('page', true) end
  return prefix .. make_page_reference_xml(first, false) ..
    config.range_separator .. make_page_reference_xml(second, false)
end

local function make_note_reference_xml(target, is_prefixed)
  local note_ref_xml = ''
  if is_prefixed then
    note_ref_xml = make_prefix_xml('note', false)
  end
  if RAW_ATTRIBUTE == 'opendocument' then
    note_ref_xml = note_ref_xml ..
      '<text:note-ref text:note-class="footnote"' ..
      ' text:reference-format="text" text:ref-name="' ..
      (spans_to_note_labels[target] or '') .. '">000</text:note-ref>'
  elseif RAW_ATTRIBUTE == 'openxml' then
    note_ref_xml = note_ref_xml ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> NOTEREF ' ..
      (spans_to_note_labels[target] or '') .. '_Note' .. ' \\h </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
      '<w:r><w:t>000</w:t></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
  end
  return note_ref_xml
end

local function make_pagenote_reference_xml(target, is_prefixed)
  local pagenote_ref_xml = ''
  if is_prefixed then
    pagenote_ref_xml = make_prefix_xml(config.pagenote_first_type, false)
  end
  if config.pagenote_first_type == 'page' then
    pagenote_ref_xml = pagenote_ref_xml ..
      make_page_reference_xml(target, false) ..
      config.pagenote_separator .. make_note_reference_xml(target, true) ..
      config.pagenote_at_end
  elseif config.pagenote_first_type == 'note' then
    pagenote_ref_xml = pagenote_ref_xml ..
      make_note_reference_xml(target, false) ..
      config.pagenote_separator .. make_page_reference_xml(target, true) ..
      config.pagenote_at_end
  else
    error('“tcrf-pagenote-first-type” must be set either to “page” or “note”.')
  end
  return pagenote_ref_xml
end

local function make_reference_xml(ref, ref_type, is_prefixed)
  local reference_xml = ''
  if ref_type == 'page' and ref.end_of_range then
    reference_xml =
      make_pagerange_reference_xml(ref.anchor, ref.end_of_range, is_prefixed)
  elseif ref_type == 'page' then
    reference_xml = make_page_reference_xml(ref.anchor, is_prefixed)
  elseif ref_type == 'note' then
    reference_xml = make_note_reference_xml(ref.anchor, is_prefixed)
  elseif ref_type == 'pagenote' then
    reference_xml = make_pagenote_reference_xml(ref.anchor, is_prefixed)
  end
  return reference_xml
end

local function make_global_prefix_xml(ref_type)
  local global_prefix_xml = ''
  local prefix_type = ref_type
  if ref_type == 'pagenote' then
    prefix_type = config.pagenote_first_type
  end
  global_prefix_xml = make_prefix_xml(prefix_type, true)
  return global_prefix_xml
end

local function make_references_xml(refs, ref_type, is_prefixed)
  local references_xml = ''
  for i = 1, #refs do
    references_xml = references_xml ..
      make_reference_xml(refs[i], ref_type, is_prefixed)
    if i < #refs then
      if i < #refs - 1 then
        references_xml = references_xml .. config.multiple_delimiter
      else
        references_xml = references_xml .. config.multiple_before_last
      end
    end
  end
  return references_xml
end

local function make_raw_content_xml(refs, ref_type, is_prefixed)
  local is_enumeration = #refs > 1
  local global_prefix = ''
  if is_enumeration and is_prefixed
    and (ref_type ~= 'pagenote'
         or pagenote_factorize_first_prefix_in_enum == 'yes')
  then
    global_prefix = make_global_prefix_xml(ref_type)
    is_prefixed = false
  end
  local references_raw_xml = make_references_xml(refs, ref_type, is_prefixed)
  return global_prefix .. references_raw_xml
end

local function make_raw_content(refs, ref_type, is_prefixed)
  local raw_content = ''
  if RAW_ATTRIBUTE == 'context' or RAW_ATTRIBUTE == 'latex' then
    raw_content = make_raw_content_tex(refs, ref_type, is_prefixed)
  else
    raw_content = make_raw_content_xml(refs, ref_type, is_prefixed)
  end
  return raw_content
end

local function format_references(refs, ref_type, is_prefixed)
  local raw_content = make_raw_content(refs, ref_type, is_prefixed)
  return pandoc.RawInline(RAW_ATTRIBUTE, raw_content)
end

local function format_enum(span)
  -- A reference is a Str contained in a span representing a label or a range of labels.
  -- A ref is a ref object produced by the function "new_ref" defined above.
  if span.classes:includes(TEXT_CROSSREF_CLASS)
    and not(is_ref_external(stringify(span.content)))
  then
    local refs = parse_references_enum(stringify(span.content))
    local ref_type = get_ref_type(span)
    local is_prefixed = if_prefixed(span)
    span.content = format_references(refs, ref_type, is_prefixed)
  end
  return span
end

return {
  { Meta = configure },
  { Meta = support_footnote_label_ConTeXt },
  { Note = set_notelabels },
  { Note = map_spans_to_notelabels },
  { Span = control_label_placement },
  { Span = labelize_span },
  { Span = format_enum }
}
