--- pretty-urls.lua – let URLs look a little nicer
---
--- Copyright: © 2022 Albert Krewinkel
--- License: MIT – see LICENSE for details
-- Ensure a recent enough pandoc version.
PANDOC_VERSION:must_be_at_least '2.7'

local stringify = pandoc.utils.stringify

local function prettify_url (link)
  -- Do not change the link if the description does not match the
  -- target
  if stringify(link.content) ~= link.target then
    return nil
  end

  link.content = link.target:gsub('^https%:%/%/', '')
  link.content = link.content:gsub('^(dx%.?)doi%.org%/', 'DOI:') --prettify DOIs
  return link
end

return {{Link = prettify_url}}