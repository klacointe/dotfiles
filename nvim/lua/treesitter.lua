require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "ruby" },

  sync_install = false,

  auto_install = true,

  ignore_install = {},

  highlight = {
    enable = true,
    disable = { "elixir" },
    additional_vim_regex_highlighting = false,
  }
}
