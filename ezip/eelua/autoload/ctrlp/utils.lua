local path = require "minipath"
local lfs = require "lfs"

local _M = {}

local ctrlp_fpath = path.join(eelua.app_path, "_.__ctrlp__")
local cached_root

function _M.open_doc()
  io.writefile(ctrlp_fpath, "")
  return App:open_doc(ctrlp_fpath)
end

local function find_root_c(mode, doc)
  if doc == nil then
    return
  end
  local fpath = doc.fullpath or ""
  if fpath == "" then
    return
  end
  return path.getdirectory(path.getabsolute(fpath))
end

local function find_root_a(mode, doc)
  local cur_file_dir = find_root_c(mode, doc)
  local cwd = lfs.currentdir()
  if not cur_file_dir then
    return cwd
  end
  if string.contains(cur_file_dir, cwd) then
    return cwd
  end
  return cur_file_dir
end

local function find_root_r(mode, doc)
  local cur_file_dir = find_root_c(mode, doc)
  if not cur_file_dir then
    return
  end

  local root_markers = { ".git" }
  local dir = cur_file_dir
  local depth = 1
  while depth < 100 do
    for _, root_marker in ipairs(root_markers) do
      local fpath = path.join(dir, root_marker)
      if lfs.exists_dir(fpath) then
        return dir
      end
    end
    local parent_dir = path.getdirectory(dir)
    if parent_dir == dir then
      break
    end
    dir = parent_dir
    depth = depth + 1
  end
end

function _M._find_root(mode, doc)
  mode = mode or ctrlp_working_path_mode
  local doc = doc or App.active_doc
  if doc and doc.fullpath and string.contains(doc.fullpath, ".__ctrlp") then
    doc = nil
  end

  local root
  for i = 1, #mode do
    local ch = mode:sub(i, i)
    if ch == "r" then
      root = find_root_r(mode, doc)
      if root then return root end
    elseif ch == "a" then
      root = find_root_a(mode, doc)
      if root then return root end
    elseif ch == "c" then
      root = find_root_c(mode, doc)
      if root then return root end
    end
  end
  return root
end

function _M.find_root(mode, doc)
  local active_doc = App.active_doc
  if active_doc and active_doc.fullpath and string.contains(active_doc.fullpath, ".__ctrlp") then
    if cached_root then
      return cached_root
    end
  end
  cached_root = _M._find_root(mode, doc)
  return cached_root
end

return _M
