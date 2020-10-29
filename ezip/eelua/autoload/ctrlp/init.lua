-- <cr> <A-Enter>  open
-- <c-r>    regex or plain
-- <esc> <c-c> <c-g>  exit
-- <c-j> <c-k>  up and down
-- <c-y>    mkdir -p
-- <c-z>  mark or unmark
-- <c-o>  open marked files

local _M = {}

local function call_meth(meth_name, ...)
  local mod_name = string.format("autoload.ctrlp.%s", ctrlp_cur_type or "default")
  local mod = require(mod_name)
  mod[meth_name](...)
end

function _M.update()
  call_meth("update")
end

function _M.on_accept()
  call_meth("on_accept")
end

return _M
