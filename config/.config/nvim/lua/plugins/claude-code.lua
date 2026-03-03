local toggle_key = "<C-,>"
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  opts = {
    terminal = {
      snacks_win_opts = {
        position = "float",
        width = 0.85,
        height = 0.85,
        border = "rounded",
        keys = {
          {
            toggle_key,
            function(self)
              self:hide()
            end,
            mode = "t",
            desc = "Hide (Ctrl+,)",
          },
        },
      },
    },
    diff_opts = {
      keep_terminal_focus = true,
    },
  },
  keys = {
    { toggle_key, "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code", mode = { "n", "x" } },
  },
}
