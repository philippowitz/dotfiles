return {
  {
    'JuliaEditorSupport/julia-vim',
    lazy = false,
    enabled = true,
    init = function()
      vim.g.latex_to_unicode_tab = 'off'
      vim.g.julia_blocks = 1
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
