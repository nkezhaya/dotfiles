return {
  {
    "mistricky/codesnap.nvim",
    build = "make",
    enabled = false,
    config = function()
      require("codesnap").setup({
        watermark = "",
      })
    end,
  },
}
