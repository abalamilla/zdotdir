return {
  "saghen/blink.cmp",
  dependencies = {
    "moyiz/blink-emoji.nvim",
  },
  opts = {
    enabled = function()
      -- Disable completion for wiki files (files under ~/vimwiki)
      local buf_path = vim.api.nvim_buf_get_name(0)
      local wiki_path = vim.fn.expand("~/vimwiki")
      local is_wiki_file = buf_path:find(vim.pesc(wiki_path), 1, true) == 1

      return not is_wiki_file and vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
    end,
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "emoji" },
      providers = {
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
        },
      },
    },
  },
}
