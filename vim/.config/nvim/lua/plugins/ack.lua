return {
  "mileszs/ack.vim",
  config = function()
    -- ack should use rg
    vim.g.ackprg = 'rg --vimgrep --type-not sql --smart-case'

    -- auto close the Quickfix list after pressing '<enter>' on a list item
    vim.g.ack_autoclose = 1

    -- any empty ack search will search for the work the cursor is on
    vim.g.ack_use_cword_for_empty_search = 1

    -- maps <leader>/ so we're ready to type the search keyword
    vim.keymap.set("n", "<leader>/", ":Ack! ", { noremap = true })

    -- don't jump to first match
    vim.cmd([[cnoreabbrev Ack Ack!]])
  end,
}
