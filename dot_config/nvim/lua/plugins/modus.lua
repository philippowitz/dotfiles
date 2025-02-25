return {
  'miikanissi/modus-themes.nvim',
  priority = 1000,
  enabled = true,
  lazy = false,
  config = function()
    require('modus-themes').setup {
      style = 'modus_operandi',
      variant = 'default',
      transparent = false,
      dim_inactive = false,
      hide_inactive_statusline = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
      on_highlights = function(highlights, colors)
        highlights.FzfLuaNormal = { fg = colors.fg_active, bg = colors.bg_active }
        highlights.FzfLuaFzfMatch = { fg = colors.blue }
      end,
    }
    vim.cmd.colorscheme 'modus'
  end,
}
