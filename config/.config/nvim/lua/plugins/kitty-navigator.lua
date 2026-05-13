return {
  "knubie/vim-kitty-navigator",
  init = function()
    vim.g.kitty_navigator_no_mappings = 1
    vim.g.kitty_navigator_enable_stack_layout = 1
    -- Ensure kitten command can find the socket
    local kitty_listen = os.getenv("KITTY_LISTEN_ON") or "unix:/tmp/mykitty"
    vim.env.KITTY_LISTEN_ON = kitty_listen
  end,
}
