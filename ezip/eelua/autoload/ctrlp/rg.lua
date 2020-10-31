local lfs = require "lfs"
local ctrlp = require "autoload.ctrlp.init"

local _M = {
  name = "rg",
  type = "cmd",
  cmd = ctrlp_rg_cmd or "rg -E GB2312 --vimgrep -F $query $root",
  must_has_query = true,
  accept = function(opts)
    local s = opts.items[1]
    local init = 1
    if s:sub(2, 2) == ":" then
      init = 3
    end
    local fpath, line, col, _ = s:match("^([^:]+):(%d+):(%d+):", init)
    if fpath and init == 3 then
      fpath = s:sub(1, 2) .. fpath
    end

    if fpath and lfs.exists_file(fpath) then
      App:open_doc(fpath)
      App.active_doc:set_cursor({
        line = tonumber(line) - 1,
        col = 0
        -- col = tonumber(col) - 1
      }, true)
    end
  end
}

function _M.run()
  ctrlp.run(_M)
end

if not ... then
  _M.run()
end

return _M
