return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function () 
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = { "elixir", "typescript", "c", "lua", "vim", "vimdoc", "query", "heex", "javascript", "html" },
      sync_install = false,
      highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = {},
      },
    })
  end
}
