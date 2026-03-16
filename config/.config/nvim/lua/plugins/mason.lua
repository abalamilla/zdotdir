return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Don't prepend mason bin to PATH (shell config handles PATH ordering)
      opts.PATH = "skip"
    end,
  },
}