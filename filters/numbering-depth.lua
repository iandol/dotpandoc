-- adjust as needed
local max_numbering_level = 3

function Header (h)
  if h.level > max_numbering_level then 
    h.classes:insert 'unnumbered'
  end
  return h
end