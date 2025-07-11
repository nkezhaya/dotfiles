return {
  {
    "junegunn/fzf",
  },

  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    config = function()
      vim.env.FZF_DEFAULT_COMMAND = 'ag -g "" --ignore "node_modules"'
      vim.keymap.set("n", "<leader>j", ":Files<CR>", { noremap = true })
    end,
  },
}
