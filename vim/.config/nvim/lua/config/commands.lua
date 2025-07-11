vim.api.nvim_create_user_command("Evimrc", function()
  vim.cmd("edit " .. vim.env.MYVIMRC)
end, {})
