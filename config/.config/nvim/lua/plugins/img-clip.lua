return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      dir_path = "assets",
      relative_to_current_file = true,
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>I", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
