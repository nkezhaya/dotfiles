vim.api.nvim_create_user_command("Evimrc", function()
  vim.cmd("edit " .. vim.env.MYVIMRC)
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

-- pgFormatter for SQL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    vim.opt_local.formatprg = "/usr/local/bin/pg_format -"
  end,
})
