return {
  {
    "oskarnurm/koda.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme koda-dark")

      local bg = "#101010"
      local fg = "#EBEBEB"
      vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg, bg = bg })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local hls = vim.fn.getcompletion("", "highlight")
          for _, name in ipairs(hls) do
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
            if ok and hl.italic then
              local new_hl = vim.deepcopy(hl)
              new_hl.italic = false
              vim.api.nvim_set_hl(0, name, new_hl)
            end
          end
        end,
      })
    end,
  },
}
