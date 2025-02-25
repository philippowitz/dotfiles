return {
  {
    'echasnovski/mini.ai',
    lazy = false,
    event = 'VeryLazy',
    opts = {
      n_lines = 500,
    },
  },
  {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'undotree',
          'toggleterm',
          'lazyterm',
          'fzf',
          'NeogitStatus',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    opts = {
      symbol = '│',
      options = { try_as_border = true },
    },
  },

  {
    'echasnovski/mini.files',
    dependencies = {
      'echasnovski/mini.icons',
    },
    keys = {
      {
        '<leader>e',
        function(...)
          if not MiniFiles.close() then
            MiniFiles.open(...)
          end
        end,
        desc = 'Toggle File[E]xplorer',
        silent = true,
        noremap = true,
      },
    },
    opts = {
      windows = {
        preview = true,
        width_preview = 50,
      },
    },
  },

  {
    'echasnovski/mini.icons',
    opts = {},
  },

  { 'echasnovski/mini.animate', version = false, enabled = false, lazy = false, opts = { cursor = { enable = false } } },
}
-- vim: ts=2 sts=2 sw=2 et
