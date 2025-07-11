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
  },
  "arcticicestudio/nord-vim",
  "Rigellute/rigel",
  "cocopon/iceberg.vim",
  "flrnd/candid.vim",
  "morhetz/gruvbox",
  "joshdick/onedark.vim",
  "altercation/vim-colors-solarized",
  { "embark-theme/vim", name = "embark" },
  "sainnhe/sonokai",
  "ghifarit53/tokyonight-vim",
  "sainnhe/everforest",
  "ayu-theme/ayu-vim",
}
