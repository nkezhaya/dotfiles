vim.api.nvim_create_user_command("Evimrc", function()
  vim.cmd("edit " .. vim.env.MYVIMRC)
end, {})

-- Update plugins
vim.api.nvim_create_user_command("Eupdate", function()
  vim.cmd("Lazy update")
end, {})

-- Autocmds
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
  desc = "Jump to the last position when opening a file",
})

-- Reload changed files
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

-- LSP format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*.ex", "*.exs", "*.heex"},
    callback = function()
      vim.lsp.buf.format()
    end,
})

-- pgFormatter for SQL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    vim.opt_local.formatprg = "/usr/local/bin/pg_format -"
  end,
})
