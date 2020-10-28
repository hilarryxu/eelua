local path = require "minipath"

local _M = {}

local ctrlp_fpath = path.join(eelua.app_path, "_.__ctrlp__")

function _M.open_doc()
  io.writefile(ctrlp_fpath, "")
  return App:open_doc(ctrlp_fpath)
end

function _M.find_root()
  for _, frame in ipairs(App.frames) do
    if frame and frame.fullpath and frame.fullpath ~= "" then
      local fpath = frame.fullpath
      if not fpath:contains(".__ctrlp") then
        return path.getdirectory(fpath)
      end
    end
  end
end

return _M
