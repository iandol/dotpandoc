-- Pandoc filter to process Mermaid code blocks with class into images.
-- Adapted from the "ABC" conversion example filter in the docs:
-- https://pandoc.org/lua-filters.html#converting-abc-code-to-music-notation
--
-- * Assumes that mermaid-cli is in the path. Please see installation
--   instructions here: https://github.com/mermaid-js/mermaid-cli#installation
-- * For HTML formats, you may alternatively use --embed-resources
-- * You can override the default format selection by passing the attribute
-- `format` with a supported value. E.g.: `{.mermaid format=png}`.
-- * You can override the default dimensions of the produced image (to
--   increase/decrease resolution) by passing the attributes `export_width` and
--   `export_height` respectively.

-- Supported formats by the Mermaid filter (as per the -h output)
local supported_formats = {
  svg = { "svg", "image/svg+xml" },
  png = { "png", "image/png" },
  pdf = { "pdf", "application/pdf" }
}

-- By default, this filter directs the Mermaid CLI to produce PNG images, but
-- for HTML and LaTeX-based output, we can choose a more appropriate format.
local default_formats = {
  html = supported_formats["svg"],
  latex = supported_formats["pdf"],
  beamer = supported_formats["pdf"]
}

-- Allows the user to override the format by setting format=<format> in the
-- attributes of the code block, e.g.: `{.mermaid format=svg}`. This function
-- will be called below to retrieve the actual format.
local function get_format (format)
  if supported_formats[format] then
    return supported_formats[format]
  else
    return supported_formats["png"]
  end
end

-- Calls the Mermaid CLI and returns the image data as output
local function render_mermaid (code, filetype, width, height, scale)
  -- Allow overwriting of the generated size optionally.
  local w = width or "3000"
  local h = height or "3000"
  local s = scale or "1P"
  -- Call signature: mmdc -e png -i - -o -
  local output = pandoc.pipe("mmdc", {
    "-e", filetype, "--width", w, "--height", h,
    "--scale", s,
    -- input and output must receive a hyphen so that the CLI reads from stdin
    -- and writes to stdout
    "-i", "-", "-o", "-"
  }, code)
  return output
end
function CodeBlock(block)
  if block.classes[1] == "mermaid" then
    -- `FORMAT` contains the Pandoc writer being used. `get_format` will
    -- return the appropriate default filetype or this writer.
    local default_format = get_format(FORMAT)
    local filetype = default_format[1]
    local mimetype = default_format[2]

    -- Allow the user to override this per codeblock
    if block.attributes['format'] then
      local custom_format = get_format(block.attr['format'])
      filetype = custom_format[1]
      mimetype = custom_format[2]
    end

    -- Optional attributes from the code block
    local export_width  = block.attributes['export_width']
    local export_height = block.attributes['export_height']
    local export_scale  = block.attributes['export_scale']  -- NEW

    -- Render mermaid with width, height, and scale
    local img = render_mermaid(block.text, filetype,
                               export_width, export_height, export_scale)
    local fname = pandoc.sha1(img) .. "." .. filetype
    pandoc.mediabag.insert(fname, mimetype, img)

    local caption
    local alt_text = "Mermaid diagram"
    if block.attributes['caption'] then
      caption = pandoc.Caption(pandoc.read(block.attributes['caption'], 'markdown-citations').blocks)
      alt_text = block.attributes['caption']
    else
      caption = pandoc.Caption()
    end

    local image = pandoc.Image({ pandoc.Str(alt_text) }, fname, "", block.attr)
    return pandoc.Figure({ image }, caption)
  end
end
