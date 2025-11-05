require("config.commands")
require("config.set")
require("config.remap")
require("config.lazy")

local local_config = vim.fn.stdpath("config") .. "/lua/config/local.lua"

if vim.fn.filereadable(local_config) == 1 then
  require("config.local")
end
