return {
  "tpope/vim-sensible",
  "tpope/vim-surround",
  "tpope/vim-projectionist",
  {
    "mattn/emmet-vim",
    config = function()
      -- Emmet settings
      vim.g.user_emmet_settings = {
        ["javascript.jsx"] = {
          extends = "jsx",
        },
      }
      
      vim.g.user_emmet_install_global = 0
      
      -- Enable emmet for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "eelixir" },
        callback = function()
          vim.cmd("EmmetInstall")
        end,
      })
    end,
  },
}