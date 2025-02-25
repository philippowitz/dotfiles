return {
  'stevearc/dressing.nvim',
  enabled = true,
  event = 'VeryLazy',
  config = function()
    require('dressing').setup {
      select = {
        backend = { 'fzf_lua' },
      },
      input = {
        border = 'single',
        override = function(conf)
          if conf.relative == 'cursor' then
            conf.col = -1
            conf.row = 0
          end
          return conf
        end,
        get_config = function(conf)
          return conf
        end,
      },
    }
  end,
}
