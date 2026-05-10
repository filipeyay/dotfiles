return {
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    config = true,
    opts = {
      dark_style_background = "#1e1e1e",

      hl_styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
        variables = { italic = false },
      },
    },

    config = function(_, opts)
      require("monokai-nightasty").setup(opts)
      require("monokai-nightasty").load()

      vim.schedule(function()
        for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })

          if ok and hl.italic then
            hl.italic = false
            vim.api.nvim_set_hl(0, group, hl)
          end
        end
      end)
    end,
  },
}
