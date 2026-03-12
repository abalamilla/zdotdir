return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "prettier" },
    },
    formatters = {
      prettier = {
        args = {
          "--stdin-filepath",
          "$FILENAME",
          "--prose-wrap",
          "always",
          "--print-width",
          "80",
        },
      },
    },
  },
}
