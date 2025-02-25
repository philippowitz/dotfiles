return {
  'maxmx03/solarized.nvim',
  enabled = false,
  lazy = false,
  priority = 1000,
  config = function()
    require('solarized').setup {
      styles = {
        comments = { bold = false },
        functions = { bold = true },
        variables = { bold = true },
      },
      variant = 'winter',
      plugins = {
        treesitter = true,
        lspconfig = true,
        navic = false,
        cmp = true,
        indentblankline = true,
        neotree = false,
        nvimtree = false,
        whichkey = true,
        dashboard = false,
        gitsigns = true,
        telescope = true,
        noice = false,
        hop = false,
        ministatusline = false,
        minitabline = false,
        ministarter = false,
        minicursorword = true,
        notify = true,
        rainbowdelimiters = true,
        bufferline = false,
        lazy = true,
        rendermarkdown = true,
      },
      on_highlights = function(colors)
        local groups = {
          -- LazyNormal = { fg = colors.base00, bg = colors.base3 },
          -- WhichKeyNormal = { fg = colors.base00, bg = colors.base3 },
          -- WinSeparator = { fg = colors.blue, bg = colors.base3 },
          FzfLuaBorder = { link = 'FloatBorder' },
          FzfLuaNormal = { link = 'LazyNormal' },
          LineNr = { fg = colors.base01, bg = colors.base3 },
          SignColumn = { link = 'LineNr' },
        }
        return groups
      end,
    }
    vim.o.background = 'light'

    vim.cmd.colorscheme 'solarized'
  end,
}
