local lfs = require "lfs"
local ctrlp = require "autoload.ctrlp.init"

local _M = {
  name = "files",
  type = "cmd",
  cmd = ctrlp_user_command or "rg --files $root",
  accept = function(opts)
    local fpath = opts.items[1]
    if lfs.exists_file(fpath) then
      App:open_doc(fpath)
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
