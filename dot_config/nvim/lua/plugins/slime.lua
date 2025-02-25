return {
  'jpalardy/vim-slime',
  lazy = false,
  init = function()
    vim.g.slime_target = 'tmux'
    vim.g.slime_no_mappings = 1
    vim.g.slime_default_config = { socket_name = 'default', target_pane = '2' }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
