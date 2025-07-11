function ColorMyPencils(color)
	color = color or "dracula"
	vim.cmd.colorscheme(color)
end

return {
  {
    "dracula/vim",
    lazy = false,
    config = function()
      ColorMyPencils()
    end,
  }
}
