local tap = {}

tap.counter = 1

tap.ok = function(assert_true, desc)
  local msg = (assert_true and "ok " or "not ok ") .. tap.counter
  if desc then
    msg = msg .. " - " .. desc
  end
  _p(msg)
  tap.counter = tap.counter + 1
end

return tap

