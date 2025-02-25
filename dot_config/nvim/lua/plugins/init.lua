return {
  {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  },

  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
  },

  {
    'ThePrimeagen/vim-be-good',
    cmd = 'VimBeGood',
  },

  {

    'NvChad/nvim-colorizer.lua',
    cmd = { 'ColorizerAttachToBuffer', 'ColorizerDetachFromBuffer' },
    opts = {},
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  {
    {
      'okuuva/auto-save.nvim',
      opts = { enabled = false },
      keys = {
        { '<leader>n', ':ASToggle<CR>', desc = 'Toggle auto-save' },
      },
    },
  },
  {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
