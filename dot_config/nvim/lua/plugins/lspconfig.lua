return {

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    -- enabled = false,
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'nvim-java/nvim-java',
        config = function()
          require('java').setup()
        end,
      },

      -- {
      --   'https://gitlab.com/schrieveslaach/sonarlint.nvim',
      --   config = function()
      --     require('sonarlint').setup {
      --       server = {
      --         cmd = {
      --           'sonarlint-language-server',
      --           -- Ensure that sonarlint-language-server uses stdio channel
      --           '-stdio',
      --           '-analyzers',
      --           -- paths to the analyzers you need, using those for python and java in this example
      --           vim.fn.stdpath 'data' .. '/mason/share/sonarlint-analyzers/sonarpython.jar',
      --           vim.fn.stdpath 'data' .. '/mason/share/sonarlint-analyzers/sonarcfamily.jar',
      --           vim.fn.stdpath 'data' .. '/mason/share/sonarlint-analyzers/sonarjava.jar',
      --         },
      --       },
      --       filetypes = {
      --         -- Tested and working
      --         'python',
      --         'cpp',
      --         'java',
      --       },
      --     }
      --   end,
      -- },

      { 'j-hui/fidget.nvim', opts = {} },
      {
        'rachartier/tiny-inline-diagnostic.nvim',
        opts = {
          preset = 'classic',
        },
      },
      { 'folke/lazydev.nvim', opts = {} },
      { 'barreiroleo/ltex-extra.nvim' },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local border = {
            { '┌', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '┐', 'FloatBorder' },
            { '│', 'FloatBorder' },
            { '┘', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '└', 'FloatBorder' },
            { '│', 'FloatBorder' },
          }
          local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
          function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            -- opts.border = opts.border or border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
          end
          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('fzf-lua').lsp_typedefs, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gS', require('fzf-lua').lsp_document_symbols, '[G]oto [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('fzf-lua').lsp_live_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local symbols = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

      for name, icon in pairs(symbols) do
        local hl = 'DiagnosticSign' .. name
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
      end

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {

        -- julials = {
        --   on_new_config = function(new_config, _)
        --     local julia = vim.fn.expand '~/.julia/environments/nvim-lspconfig/bin/julia'
        --     if require('lspconfig').util.path.is_file(julia) then
        --       new_config.cmd[1] = julia
        --     end
        --   end,
        --   -- ...,
        -- },
        --
        -- jdtls = {},
        --
        -- julials = {
        --   runtimeCompletions = true,
        -- },
        --
        -- ltex = {
        --   filetypes = { 'markdown', 'tex', 'typst', 'julia' },
        --   on_attach = function()
        --     require('ltex_extra').setup {
        --       load_langs = { 'en-GB', 'de-DE' },
        --     }
        --   end,
        --   settings = {
        --     ltex = {
        --       enabled = { 'julia' },
        --       language = 'en-GB',
        --       additionalRules = {
        --         languageModel = '~/ngrams/',
        --       },
        --     },
        --   },
        -- },
        -- r_language_server = {
        --   settings = {
        --     r_language_server = {
        --       cmd = { 'R', '--slave', '-e', 'languageserver::run()' },
        --     },
        --   },
        -- },

        -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
        -- lua_ls = {
        --   settings = {
        --     Lua = {
        --       completion = {
        --         callSnippet = 'Replace',
        --       },
        --     },
        --   },
        -- },
        -- tinymist = {
        --   --- todo: these configuration from lspconfig maybe broken
        --   single_file_support = true,
        --   root_dir = function()
        --     return vim.fn.getcwd()
        --   end,
        --   settings = {
        --     exportPdf = 'onType',
        --   },
        -- },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
          jdtls = function()
            require('lspconfig').jdtls.setup {}
          end,
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
