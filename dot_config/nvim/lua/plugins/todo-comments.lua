-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },

    keys = {
      {
        '<leader>st',
        function()
          require('todo-comments.fzf').todo()
        end,
        desc = 'Todo',
      },
      {
        '<leader>sT',
        function()
          require('todo-comments.fzf').todo { keywords = { 'TODO', 'FIX', 'FIXME' } }
        end,
        desc = 'Todo/Fix/Fixme',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
