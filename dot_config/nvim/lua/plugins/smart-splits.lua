return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'kwkarlwang/bufresize.nvim', opts = {} },
  },
  config = function()
    require('smart-splits').setup {
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = {
        'nofile',
        'quickfix',
        'prompt',
      },
      ignored_filetypes = { 'minifiles' },

      default_amount = 3,
      resize_mode = {
        hooks = {
          on_leave = require('bufresize').register,
        },
      },
    }
  end,
}
-- vim: ts=2 sts=2 sw=2 et
--
