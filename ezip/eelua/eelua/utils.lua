local ffi = require"ffi"
local eelua = require"eelua"

local ffi_cast = ffi.cast

function eelua.iif(expr, trueval, falseval)
  if (expr) then
    return trueval
  else
    return falseval
  end
end

local _M = {
  iif = eelua.iif,
}

return _M
