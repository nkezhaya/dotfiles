return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  -- Only load for Elixir files, not on BufReadPre
  ft = { "elixir", "eelixir", "heex", "surface" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = { enable = false },
      elixirls = {
        enable = true,
        settings = elixirls.settings {
          dialyzerEnabled = true,
          enableTestLenses = false,
          fetchDeps = false,
          suggestSpecs = false,
          autoInsertRequiredAlias = false,
          signatureAfterComplete = false,
        },
        on_attach = function(client, bufnr)
          -- Disable semantic tokens for faster rendering
          client.server_capabilities.semanticTokensProvider = nil
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
