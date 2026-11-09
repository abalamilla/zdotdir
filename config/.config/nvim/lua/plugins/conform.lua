return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "prettier" },
      php = { "php_cs_fixer" },
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
