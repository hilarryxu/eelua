eelua.add_plugin_command {
  name = "pl_ctrlp",
  desc = "CtrlP",
  func = function()
    local mod = require("autoload.ctrlp.files")
    mod.run()
  end
}
