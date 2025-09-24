return {
  {
    "neovim/nvim-lspconfig",
    config = function()
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
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
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
