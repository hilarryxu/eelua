local unicode = require "unicode"
local lfs = require "lfs"
local utils = require "autoload.ctrlp.utils"

local _M = {
  name = "files"
}

function _M.run()
  ctrlp_cur_type = _M.name
  local prev_doc = App.active_doc
  utils.open_doc()
  _M.update("", { prev_doc = prev_doc })
end

function _M.update(query, opts)
  opts = opts or {}
  local doc = App.active_doc
  local query = query or doc:getline(".")
  local i, j = query:find("> ", 1, true)
  if j then
    query = query:sub(j + 1)
  end
  local prompt_line
  local content

  local root = utils.find_root(nil, opts.prev_doc) or "."
  if query ~= "" then
    prompt_line = string.format("%s > %s", _M.name:upper(), query)
    content = os.outputof(string.format([[rg --files "%s" | rg "%s"]], root, query))
  else
    prompt_line = string.format("%s > ", _M.name:upper())
    content = os.outputof(string.format([[rg --files "%s"]], root))
  end
  content = unicode.A(content:gsub("\r\n", "\n"))

  local text = prompt_line .. "\n" .. content
  doc.text = text
  doc:gotoline(0)
  doc:send_command(6)  -- ECC_LINEEND
end

function _M.on_accept()
  local doc = App.active_doc
  local cursor = doc.cursor
  local fpath
  if cursor.line > 0 then
    fpath = string.trim(doc:getline("."))
  else
    fpath = string.trim(doc:getline(1))
  end
  if lfs.exists_file(fpath) then
    App:open_doc(fpath)
  end
end

if not ... then
  _M.run()
end

return _M
