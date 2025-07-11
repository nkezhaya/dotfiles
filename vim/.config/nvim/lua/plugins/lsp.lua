return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Global LSP keymaps that apply to all LSP servers
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          
          -- Go to definition in new tab (replaces CoC gf)
          vim.keymap.set("n", "gf", function()
            vim.cmd("tab split")
            vim.lsp.buf.definition()
          end, opts)
          
          -- Go to definition in current buffer (replaces CoC gs)
          vim.keymap.set("n", "gs", vim.lsp.buf.definition, opts)
        end,
      })
      
      -- clangd setup
      lspconfig.clangd.setup({
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp" },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
      })
    end,
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup({
        tsserver_path = "/opt/homebrew/bin/typescript-language-server"
      })
    end,
  },
}
