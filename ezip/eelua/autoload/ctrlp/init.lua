-- <cr> <A-Enter>  open
-- <c-r>    regex or plain
-- <esc> <c-c> <c-g>  exit
-- <c-j> <c-k>  up and down
-- <c-f> <c-b>  toggle type
-- <c-y>    mkdir -p
-- <c-z>  mark or unmark
-- <c-o>  open marked files

local string = require "string"
local path = require "minipath"
local unicode = require "unicode"
local utils = require "autoload.ctrlp.utils"

local str_fmt = string.format
local tconcat = table.concat

local _M = {}

function _M.refresh()
  local doc = App.active_doc
  local query = doc:getline(".")
  local i, j = query:find("> ", 1, true)
  if j then
    query = query:sub(j + 1)
  end

  _M.run(_ctrlp, {
    refresh = true,
    query = query
  })
end

function _M.accept()
  local doc = App.active_doc
  local cursor = doc.cursor
  local s
  if cursor.line > 0 then
    s = doc:getline(".")
  else
    s = doc:getline(1)
  end

  local opts = {
    items = { s }
  }
  _ctrlp.accept(opts)
end

local function get_cur_file_dir()
  local doc = App.active_doc
  if doc == nil then return end

  local fpath = doc.fullpath or ""
  if fpath == "" or fpath:contains(".__ctrlp") then return end
  return path.getdirectory(path.getabsolute(fpath))
end

local function build_prompt_line(opts)
  local prompt_line = str_fmt(
    "%s%s%s",
    opts.name:upper(),
    opts.prompt or "> ",
    opts.query or ""
  )
  return prompt_line
end

function _M.run(opts, extra_opts)
  opts = opts or {}
  extra_opts = extra_opts or {}
  _ctrlp = opts
  local cur_file_dir = get_cur_file_dir()

  ctrlp_cur_type = opts.name
  utils.open_doc()
  local doc = App.active_doc

  local root = utils.find_root {
    cur_file_dir = cur_file_dir,
    refresh = extra_opts.refresh
  } or "."
  local query = extra_opts.query or opts.query
  query = query or ""

  local content = ""
  local ext_type = opts.type
  if ext_type == "cmd" then
    if not (opts.must_has_query and query == "") then
      local cmd = opts.cmd
      local cmd_opts = {
        query = utils.shellescape(query),
        root = utils.shellescape(root)
      }
      if type(opts.cmd) == "function" then
        cmd = opts.cmd(cmd_opts)
      end
      cmd = cmd:gsub("%$(%w+)", cmd_opts)
      content = os.outputof(cmd)
      if content and content ~= "" then
        content = unicode.A(content:gsub("\r\n", "\n"))
      end
    end
  elseif ext_type == "list" then
    content = tconcat(opts.list, "\n")
  end

  local prompt_line = build_prompt_line {
    name = opts.name,
    query = query,
    prompt = opts.prompt
  }

  local text = prompt_line .. "\n" .. content
  doc.text = text
  doc:gotoline(1)
  doc:send_command(6)  -- ECC_LINEEND
  App:send_command(57603)  -- Save
end

function _M.toggle_type(step)
  local cur_type = _ctrlp and _ctrlp.name or ""
  local idx = table.indexof(ctrlp_types, cur_type)
  if not idx then return end

  idx = idx + tonumber(step)
  if idx > #ctrlp_types then
    idx = 1
  elseif idx < 1 then
    idx = #ctrlp_types
  end

  local next_type = ctrlp_types[idx]
  local mod_name = string.format("autoload.ctrlp.%s", next_type)
  _ctrlp = require(mod_name)
  _M.run(_ctrlp, { refresh = true })
end

return _M
