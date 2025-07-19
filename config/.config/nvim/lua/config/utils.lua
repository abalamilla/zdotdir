-- Utility function to get the hostname
local isWorkBox = vim.fn.hostname():match("^WK")

return {
  isWorkBox
}
