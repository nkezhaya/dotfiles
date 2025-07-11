vim.g.mapleader = ","

vim.keymap.set('n', '<leader>/', ':Ack! ', { noremap = true })
vim.keymap.set('n', '<leader>|', ':vsplit<CR>', { noremap = true })
vim.keymap.set('n', '<leader>-', ':split<CR>', { noremap = true })
vim.keymap.set('n', '<leader>t', ':tab split<CR>', { noremap = true })
