return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root(), reveal = true })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
  },
  opts = {
    window = {
      position = "current",
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
      bind_to_cwd = true,
    },
    source_selector = {
      winbar = true,
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.cmd([[
							setlocal number
							setlocal relativenumber
							setlocal cursorline
							]])
        end,
      },
    },
  },
}
