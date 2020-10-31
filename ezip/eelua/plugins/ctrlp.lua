ctrlp_types = ctrlp_types or { "files", "rg" }
ctrlp_max_results = ctrlp_max_results or 0
ctrlp_working_path_mode = ctrlp_working_path_mode or "ra"
-- ctrlp_regexp
-- ctrlp_open_single_match

eelua.add_plugin_command {
  name = "pl_ctrlp",
  desc = "CtrlP",
  func = function()
    local mod_files = require("autoload.ctrlp.files")
    mod_files.run()
  end
}

eelua.add_console_command {
  match = "^CtrlP$",
  func = function(cmd_name, cmdline)
    local mod_files = require("autoload.ctrlp.files")
    mod_files.run()
  end
}

eelua.add_console_command {
  match = "^CtrlPRg$",
  func = function(cmd_name, cmdline)
    local mod = require("autoload.ctrlp.rg")
    mod.run()
  end
}
