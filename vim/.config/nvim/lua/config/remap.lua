vim.g.mapleader = ","

-- go to prev/next error
vim.keymap.set('n', '<leader>e', vim.diagnostic.goto_next, { noremap = true })
vim.keymap.set('n', '<leader>E', vim.diagnostic.goto_prev, { noremap = true })

vim.keymap.set('n', '<leader>|', ':vsplit<CR>', { noremap = true })
vim.keymap.set('n', '<leader>-', ':split<CR>', { noremap = true })
vim.keymap.set('n', '<leader>t', ':tab split<CR>', { noremap = true })

-- While in visual mode, <C-r> to search and replace highlighted text
vim.keymap.set('v', '<C-r>', '"hy:%s/<C-r>h//gc<left><left><left>', { noremap = true })

-- SQL formatting with pg_format
vim.keymap.set('v', '<C-f>', '<ESC>:\'<,\'>! pg_format --no-space-function --function-case 2<CR>', { noremap = true })
