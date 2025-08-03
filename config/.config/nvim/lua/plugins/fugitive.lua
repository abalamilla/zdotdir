return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gc", ":Git commit<CR>", desc = "Fugitive commit" },
    { "<leader>gp", ":Git push<CR>", desc = "Fugitive push" },
    { "<leader>gl", ":Git pull<CR>", desc = "Fugitive pull" },
    -- { "<leader>gd", ":Git diff<CR>", desc = "Fugitive diff" },
    { "<leader>gb", ":Git blame<CR>", desc = "Fugitive blame" },
    { "<leader>gm", ":Git move<CR>", desc = "Fugitive move" },
    { "<leader>gD", ":Git delete<CR>", desc = "Fugitive delete" },
  },
}
