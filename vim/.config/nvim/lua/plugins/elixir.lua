return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = {enable = false},
      elixirls = {
        enable = true,
        cmd = "/Users/nkezhaya/Code/elixir-ls/release/language_server.sh",
        settings = elixirls.settings {
          dialyzerEnabled = true,
          enableTestLenses = false,
        },
        on_attach = function(client, bufnr)
        end,
      },
      projectionist = {
        enable = true
      }
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
