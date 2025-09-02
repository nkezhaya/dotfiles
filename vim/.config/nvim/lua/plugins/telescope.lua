return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', 'fg', builtin.live_grep, { desc = 'Telescope live grep' })

    local actions = require("telescope.actions")
    require("telescope").setup{
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close
          },
        },
      }
    }
  end,
}
