return {
  "mfussenegger/nvim-jdtls",
  opts = {
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = "JavaSE-22",
              path = "/usr/local/Cellar/openjdk/22.0.2/",
            },
          },
        },
      },
    },
  },
}
