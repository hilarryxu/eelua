--
-- os.lua
-- Additions to the OS namespace.
-- Copyright (c) 2002-2011 Jason Perkins and the Premake project
--


--
-- Same as os.execute(), but accepts string formatting arguments.
--

function os.executef(cmd, ...)
  cmd = string.format(cmd, unpack(arg))
  return os.execute(cmd)
end



--
-- An overload of the os.mkdir() function, which will create any missing
-- subdirectories along the path.
--

local builtin_mkdir = os.mkdir
function os.mkdir(p)
  local dir = iif(p:startswith("/"), "/", "")
  for part in p:gmatch("[^/]+") do
    dir = dir .. part

    if (part ~= "" and not path.isabsolute(part) and not os.isdir(dir)) then
      local ok, err = builtin_mkdir(dir)
      if (not ok) then
        return nil, err
      end
    end

    dir = dir .. "/"
  end

  return true
end



--
-- Run a shell command and return the output.
--

function os.outputof(cmd)
  local pipe = io.popen(cmd)
  local result = pipe:read('*a')
  pipe:close()
  return result
end

