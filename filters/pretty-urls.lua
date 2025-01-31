--- pretty-urls.lua – let URLs look a little nicer
---
--- Copyright: © 2022 Albert Krewinkel
--- License: MIT – see LICENSE for details
-- Ensure a recent enough pandoc version.
PANDOC_VERSION:must_be_at_least '2.7'

local stringify = pandoc.utils.stringify

local function prettify_url (link)
  -- Do not change the link if the description does not match the
  -- target and it is not an autolink (marked by the 'uri' class).
  if stringify(link.content) ~= link.target and
     not link.classes:includes 'uri' then
    return nil
  end

  -- Remove http and https protocol prefix
  local is_unsafe_protocol = link.target:match '^http%:%/%/' ~= nil
  link_text = link.target
    :gsub('^https?%:%/%/', '')
    :gsub('^(d?x?%.?)doi%.org%/', 'doi:') --prettify DOIs

  if is_unsafe_protocol then
    link_text = link_text .. ' 🔓'
  end
  link.content = {pandoc.Str(link_text)}

  -- fix DOI links
  link.target = link.target:gsub('^doi%:', 'https://doi.org/')

  return link
end

return {{Link = prettify_url}}
