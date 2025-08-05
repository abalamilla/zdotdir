return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gfs", ":G<CR>", desc = "Fugitive status"},
    { "<leader>gfc", ":Git commit<CR>", desc = "Fugitive commit" },
    { "<leader>gfp", ":Git -p push<CR>", desc = "Fugitive push" },
    { "<leader>gfl", ":Git -p pull<CR>", desc = "Fugitive pull" },
    { "<leader>gfd", ":Gdiffstlit<CR>", desc = "Fugitive diff" },
    { "<leader>gfb", ":Git blame<CR>", desc = "Fugitive blame" },
    { "<leader>gfm", ":Git move<CR>", desc = "Fugitive move" },
    { "<leader>gfD", ":Git delete<CR>", desc = "Fugitive delete" },
  },
}
