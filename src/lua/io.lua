--
-- io.lua
-- Additions to the I/O namespace.
-- Copyright (c) 2008-2009 Jason Perkins and the Premake project
--


--
-- Open an overload of the io.open() function, which will create any missing
-- subdirectories in the filename if "mode" is set to writeable.
--

local builtin_open = io.open
function io.open(fname, mode)
  if (mode) then
    if (mode:find("w")) then
      local dir = path.getdirectory(fname)
      ok, err = os.mkdir(dir)
      if (not ok) then
        error(err, 0)
      end
    end
  end
  return builtin_open(fname, mode)
end

