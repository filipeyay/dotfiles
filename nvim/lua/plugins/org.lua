return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/Documentos/Org/**/*",
        org_default_notes_file = "~/Documentos/Org/refile.org",
      })

      -- Experimental LSP support
      vim.lsp.enable("org")
    end,
  },
}
