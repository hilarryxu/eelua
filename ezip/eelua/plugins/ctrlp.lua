ctrlp_max_results = ctrlp_max_results or 0
ctrlp_regexp = ctrlp_regexp or 0
ctrlp_working_path_mode = ctrlp_working_path_mode or "ra"
ctrlp_root_markers = ctrlp_root_markers or {}
ctrlp_user_command = ctrlp_user_command or "rg --files %s"
-- ctrlp_open_single_match

local mod_files = require("autoload.ctrlp.files")

eelua.add_plugin_command {
  name = "pl_ctrlp",
  desc = "CtrlP",
  func = function()
    mod_files.run()
  end
}

eelua.add_console_command {
  match = "^CtrlP$",
  func = function(name, cmdline)
    mod_files.run()
  end
}
