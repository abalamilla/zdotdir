local close_panel = { "n", "<esc>", "", { desc = "Close file panel" } }

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>gdvc", ":DiffviewClose<CR>", desc = "Close Diffview" },
    { "<leader>gdvo", ":DiffviewOpen<CR>", desc = "Open Diffview" },
    { "<leader>gdvl", ":DiffviewLog<CR>", desc = "Open Diffview Log" },
    { "<leader>gdvh", ":DiffviewFileHistory<CR>", desc = "Open Diffview File History" },
    {
      "<leader>gdvg",
      function()
        local grep_pattern = vim.fn.input("Grep pattern: ")
        if grep_pattern ~= "" then
          vim.cmd("DiffviewFileHistory --grep=" .. grep_pattern)
        end
      end,
      desc = "Diffview File History with grep",
    },
  },
  opts = {
    keymaps = {
      file_panel = {
        close_panel,
      },
      file_history_panel = {
        close_panel,
      },
    },
  },
}
