return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gFs", ":G<CR>", desc = "Fugitive status" },
    {
      "<leader>gFo",
      function()
        vim.ui.input({ prompt = "Open file at revision: ", default = "HEAD" }, function(rev)
          if rev and rev ~= "" then
            vim.cmd("Gvsplit " .. rev .. ":%")
          end
        end)
      end,
      desc = "Fugitive open file at revision",
    },
    { "<leader>gFp", ":Git -p push<CR>", desc = "Fugitive push" },
    { "<leader>gFl", ":Git -p pull<CR>", desc = "Fugitive pull" },
    { "<leader>gFd", ":Gdiffsplit<CR>", desc = "Fugitive diff" },
    { "<leader>gFb", ":Git blame<CR>", desc = "Fugitive blame" },
    {
      "<leader>gFm",
      function()
        vim.ui.input({ prompt = "Rename to: ", default = vim.fn.expand("%:t") }, function(name)
          if name and name ~= "" then
            vim.cmd("GRename " .. vim.fn.fnameescape(name))
          end
        end)
      end,
      desc = "Fugitive rename (git mv)",
    },
    { "<leader>gFD", ":GDelete<CR>", desc = "Fugitive delete (git rm)" },
  },
}
