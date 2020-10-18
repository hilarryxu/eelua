local fn = App.active_doc.fullpath
if fn ~= "" and not fn:contains([[eelua\scripts\F5.lua]]) then
  if fn:endswith(".lua") then
    dofile(fn)
  end
end
