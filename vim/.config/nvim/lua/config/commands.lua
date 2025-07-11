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

-- EEx highlighting in .heex files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.html.heex",
  callback = function()
    vim.opt_local.syntax = "eelixir"
  end,
})

-- pgFormatter for SQL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    vim.opt_local.formatprg = "/usr/local/bin/pg_format -"
  end,
})

-- EEx highlighting in Elixir modules
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.ex,*.exs",
  callback = function()
    vim.cmd([[
      syntax region elixirTemplateSigil matchgroup=elixirSigilDelimiter keepend start=+\~E\z("""\)+ end=+^\s*\z1+ skip=+\\"+ contains=@HTML fold
    ]])
  end,
})
