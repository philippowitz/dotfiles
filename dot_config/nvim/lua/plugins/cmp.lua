return {
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter' },
    version = false,
    dependencies = {
      { 'onsails/lspkind.nvim' },
      {
        'windwp/nvim-autopairs',
        opts = {
          fast_wrap = {},
          disable_filetype = { 'TelescopePrompt', 'vim' },
        },
        config = function(_, opts)
          require('nvim-autopairs').setup(opts)
          -- setup cmp for autopairs
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
      },
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      'R-nvim/cmp-r',
      'micangl/cmp-vimtex',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      -- local lspkind = require 'lspkind'

      local kind_icons = {
        Array = '󰅲',
        Boolean = '⊶',
        Codeium = '󰨊',
        Control = '',
        Collapsed = '',
        Copilot = '',
        Key = '',
        Namespace = '󰙅',
        Null = '',
        Number = '',
        Object = '',
        Package = '',
        String = '',
        TabNine = '󰚩',

        Text = ' ',
        Method = ' ',
        Function = ' ',
        Constructor = ' ',
        Field = 'ﴲ ',
        Variable = ' ',
        Class = ' ',
        Interface = 'ﰮ ',
        Module = ' ',
        Property = '襁',
        Unit = ' ',
        Value = ' ',
        Enum = ' ',
        Keyword = ' ',
        Snippet = ' ',
        Color = ' ',
        File = ' ',
        Reference = ' ',
        Folder = ' ',
        EnumMember = ' ',
        Constant = ' ',
        Struct = 'ﳤ ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' ',
      }
      -- luasnip.config.setup {}

      cmp.setup {
        -- matching = {
        --   disallow_fuzzy_matching = false,
        --   disallow_partial_matching = false,
        --   disallow_prefix_unmatching = false,
        --   disallow_fullfuzzy_matching = false,
        --   disallow_partial_fuzzy_matching = false,
        --   disallow_symbol_nonprefix_matching = false,
        -- },
        -- view = {
        --   entries = "native",
        -- },
        formatting = {
          expandable_indicator = true,
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, vim_item)
            -- Truncate entries longer than MAX_LABEL_WIDTH characters.
            -- From https://github.com/hrsh7th/nvim-cmp/discussions/609#discussioncomment-1844480
            local MAX_LABEL_WIDTH = 80
            local label = vim_item.abbr
            local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
            if truncated_label ~= label then
              vim_item.abbr = truncated_label .. '…'
            end

            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)

            --if entry.source.name == "vimtex" then
            --    return vim_item
            --end
            vim_item.menu = ({
              buffer = '[Buffer]',
              nvim_lsp = '[LSP]',
              luasnip = '[LuaSnip]',
              nvim_lua = '[Nvim lua]',
              --vimtex = "[Vimtex]" .. (vim_item.menu ~= nil and vim_item.menu or ""),
              vimtex = vim_item.menu,
            })[entry.source.name]

            return vim_item
          end,
        },
        -- performance = {
        --   max_view_entries = 8,
        -- },

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menuone,noinsert,noselect' },
        window = {
          -- completion = cmp.config.window.bordered {
          --   scrollbar = false,
          --   border = 'single',
          --   -- winhighlight = "Normal:None,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          -- },
          -- documentation = cmp.config.window.bordered({
          --   border = "single",
          --   -- winhighlight = "Normal:None,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          -- }),
        },

        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping.abort(),
          -- Select the [n]ext item
          -- ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-n>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete { reason = cmp.ContextReason.Auto }
            end
          end),
          -- Select the [p]revious item
          -- ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-p>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            else
              cmp.complete { reason = cmp.ContextReason.Auto }
            end
          end),
          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete { reason = cmp.ContextReason.Auto },
          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'luasnip' },
          { name = 'async_path' },
          { name = 'cmp_r' },
          { name = 'vimtex' },
          { name = 'orgmode' },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
