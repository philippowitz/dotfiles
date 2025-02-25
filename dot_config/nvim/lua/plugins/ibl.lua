return {
  'lukas-reineke/indent-blankline.nvim',
  event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
    },
    scope = { enabled = false },
    exclude = {
      filetypes = {
        'help',
        'NvimTree',
        'Trouble',
        'trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'lazyterm',
      },
    },
  },
  main = 'ibl',
}
-- vim: ts=2 sts=2 sw=2 et
