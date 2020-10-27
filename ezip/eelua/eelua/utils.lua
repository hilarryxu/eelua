local _M = {}

function _M.iif(expr, trueval, falseval)
  if (expr) then
    return trueval
  else
    return falseval
  end
end

return _M
