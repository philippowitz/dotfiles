return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  config = function()
    local palette = require('modus-themes.colors').modus_operandi
    local colors = {
      bg = palette.bg_main,
      fg = palette.fg_main,
      yellow = palette.yellow,
      cyan = palette.cyan,
      green = palette.green,
      orange = palette.rust,
      violet = palette.pink,
      magenta = palette.magenta,
      blue = palette.blue,
      red = palette.red,
    }

    -- colors solarized
    -- local palette = require('solarized.utils').get_colors()
    -- local colors = {
    --   bg = palette.base3,
    --   fg = palette.base00,
    --   yellow = palette.yellow,
    --   cyan = palette.cyan,
    --   green = palette.green,
    --   orange = palette.orange,
    --   violet = palette.violet,
    --   magenta = palette.magenta,
    --   blue = palette.blue,
    --   red = palette.red,
    -- }

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand '%:t') ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand '%:p:h'
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    -- local getGithubUsername = function()
    --   local handle = io.popen 'git config user.name'
    --   local result = ' ' .. handle:read '*a'
    --   return string.sub(result, 1, -2)
    -- end

    -- Config
    local config = {
      options = {
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',
        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statusline
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left {
      function()
        return ''
      end,
      color = function()
        local mode_color = {
          n = colors.red,
          i = colors.green,
          v = colors.blue,
          [''] = colors.blue,
          V = colors.blue,
          c = colors.magenta,
          no = colors.red,
          s = colors.orange,
          S = colors.orange,
          ic = colors.yellow,
          R = colors.violet,
          Rv = colors.violet,
          cv = colors.red,
          ce = colors.red,
          r = colors.cyan,
          rm = colors.cyan,
          ['r?'] = colors.cyan,
          ['!'] = colors.red,
          t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
    }

    -- ins_left {
    --   'mode',
    --   color = function()
    --     local mode_color = {
    --       n = colors.red,
    --       i = colors.green,
    --       v = colors.blue,
    --       [''] = colors.blue,
    --       V = colors.blue,
    --       c = colors.magenta,
    --       no = colors.red,
    --       s = colors.orange,
    --       S = colors.orange,
    --       ic = colors.yellow,
    --       R = colors.violet,
    --       Rv = colors.violet,
    --       cv = colors.red,
    --       ce = colors.red,
    --       r = colors.cyan,
    --       rm = colors.cyan,
    --       ['r?'] = colors.cyan,
    --       ['!'] = colors.red,
    --       t = colors.red,
    --     }
    --     return { fg = mode_color[vim.fn.mode()], gui = 'bold' }
    --   end,
    --   icons_enabled = true,
    -- }

    ins_left {
      'filesize',
      icons_enabled = true,
      cond = conditions.buffer_not_empty,
    }

    -- ins_left {
    --   'filetype',
    --   icons_enabled = false,
    -- }

    ins_left {
      'filename',
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, gui = 'bold' },
    }

    ins_left { 'location' }
    ins_left { 'progress', color = { fg = colors.fg, gui = 'bold' } }

    ins_left {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = true,
      diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.blue },
        hint = { fg = colors.cyan },
      },
    }

    ins_left {
      function()
        return '%='
      end,
    }

    ins_left {
      -- Lsp server name .
      function()
        local msg = 'No Active Lsp'
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
          return msg
        end
        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            return client.name
          end
        end
        return msg
      end,
      icon = ' ',
      color = { fg = colors.fg },
    }

    -- ins_right {
    --   getGithubUsername,
    --   icons_enabled = false,
    --   color = { fg = colors.cyan },
    -- }

    ins_right {
      'o:encoding',
      fmt = string.upper,
      cond = conditions.hide_in_width,
      color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
      'fileformat',
      fmt = string.upper,
      icons_enabled = false,
      color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
      'branch',
      icon = '',
      color = { fg = colors.violet, gui = 'bold' },
    }

    ins_right {
      'diff',
      symbols = { added = ' ', modified = '◉ ', removed = ' ' },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
      },
      cond = conditions.hide_in_width,
    }

    require('lualine').setup(config)
  end,
}
