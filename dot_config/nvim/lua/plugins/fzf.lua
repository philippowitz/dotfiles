return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  dependencies = {
    { 'echasnovski/mini.icons' },
  },
  config = function()
    local actions = require 'fzf-lua.actions'

    require('fzf-lua').setup {
      'default-title',
      fzf_colors = true,
      winopts = {
        backdrop = 100,
        -- border = "single",
        border = 'none',
        preview = {
          vertical = 'down:60%', -- up|down:size
          horizontal = 'right:60%', -- right|left:size
          layout = 'vertical', -- horizontal|vertical|flex
          flip_columns = 120, -- #cols to switch to horizontal on flex
          -- border = "border-sharp",
          border = 'none',
        },
        on_create = function() end,
      },

      keymap = {
        builtin = {
          -- neovim `:tmap` mappings for the fzf win
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          -- Only valid with the 'builtin' previewer
          ['<F3>'] = 'toggle-preview-wrap',
          ['<F4>'] = 'toggle-preview',
          -- Rotate preview clockwise/counter-clockwise
          ['<F5>'] = 'toggle-preview-ccw',
          ['<F6>'] = 'toggle-preview-cw',
          ['<S-down>'] = 'preview-page-down',
          ['<S-up>'] = 'preview-page-up',
          ['<S-left>'] = 'preview-page-reset',
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
          -- fzf '--bind=' options
          ['ctrl-z'] = 'abort',
          -- ['ctrl-u'] = false,
          ['ctrl-f'] = 'half-page-down',
          ['ctrl-b'] = 'half-page-up',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['alt-a'] = 'toggle-all',
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ['f3'] = 'toggle-preview-wrap',
          ['f4'] = 'toggle-preview',
          ['ctrl-d'] = 'preview-page-down',
          ['ctrl-u'] = 'preview-page-up',
        },
      },
      actions = {
        files = {
          ['default'] = actions.file_edit,
          ['ctrl-o'] = actions.file_edit_or_qf,
          ['ctrl-s'] = actions.file_split,
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-t'] = actions.file_tabedit,
          ['ctrl-q'] = actions.file_sel_to_qf,
          ['alt-l'] = actions.file_sel_to_ll,
        },
        buffers = {
          ['default'] = actions.buf_edit,
          ['ctrl-s'] = actions.buf_split,
          ['ctrl-o'] = actions.buf_edit,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-t'] = actions.buf_tabedit,
        },
      },

      fzf_opts = {
        ['--info'] = 'inline-right',
        ['--ansi'] = true,
        ['--height'] = '100%',
        ['--layout'] = 'reverse',
        ['--border'] = 'none',
        ['--prompt'] = '❯ ',
        ['--pointer'] = ' ',
        ['--marker'] = '❯ ',
        ['--no-scrollbar'] = '',
        ['--no-separator'] = '',
        ['--header'] = ' ',
        ['--cycle'] = '',
      },
      fzf_tmux_opts = { ['-p'] = '80%,80%', ['--margin'] = '0,0' },

      defaults = {
        no_header = false, -- hide grep|cwd header?
        no_header_i = true, -- hide interactive header?
        multiprocess = true,
        prompt = '❯ ',
        live_ast_prefix = false,
        trim_entry = true,
        fzf_args = '--bind=change:first',
        fzf_opts = {
          ['--info'] = 'inline-right',
          ['--ansi'] = true,
          ['--height'] = '100%',
          ['--layout'] = 'reverse',
          ['--border'] = 'none',
          ['--prompt'] = '❯ ',
          ['--pointer'] = ' ',
          ['--marker'] = '❯ ',
          ['--no-scrollbar'] = '',
          ['--no-separator'] = '',
          ['--header'] = ' ',
          ['--cycle'] = '',
        },
      },
      files = {
        prompt = '❯ ',
        cwd_header = true,
        cwd_prompt = false,
      },
      grep = {
        multiprocess = true, -- run command in a separate process
        git_icons = false, -- show git icons?
        file_icons = true, -- show file icons?
        color_icons = true, -- colorize file|git icons
        actions = {
          ['ctrl-g'] = { actions.grep_lgrep },
        },
        no_header = false, -- hide grep|cwd header?
        no_header_i = false, -- hide interactive header?
      },
      oldfiles = {
        winopts = {
          title = ' Recent Files ',
          title_pos = 'center',
        },
        cwd_only = false,
        stat_file = true, -- verify files exist on disk
        include_current_session = true, -- include bufs from current session
      },
      tabs = {
        prompt = ' ❯ ',
        tab_title = 'Tab',
        tab_marker = '<<',
        file_icons = true, -- show file icons?
        color_icons = true, -- colorize file|git icons
        actions = {
          -- actions inherit from 'actions.buffers' and merge
          ['default'] = actions.buf_switch,
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
        fzf_opts = {
          -- hide tabnr
          ['--delimiter'] = '[\\):]',
          ['--with-nth'] = '2..',
        },
      },
      lines = {
        prompt = ' ❯ ',
        previewer = 'builtin', -- set to 'false' to disable
        show_unloaded = true, -- show unloaded buffers
        show_unlisted = false, -- exclude 'help' buffers
        no_term_buffers = true, -- exclude 'term' buffers
        fzf_opts = {
          -- do not include bufnr in fuzzy matching
          -- tiebreak by line no.
          ['--delimiter'] = '[\\]:]',
          ['--nth'] = '2..',
          ['--tiebreak'] = 'index',
          ['--tabstop'] = '1',
        },
        -- actions inherit from 'actions.buffers' and merge
        actions = {
          ['default'] = actions.buf_edit_or_qf,
          ['alt-q'] = actions.buf_sel_to_qf,
          ['alt-l'] = actions.buf_sel_to_ll,
        },
      },
      blines = {
        previewer = 'builtin', -- set to 'false' to disable
        prompt = ' ❯ ',
        show_unlisted = true, -- include 'help' buffers
        no_term_buffers = false, -- include 'term' buffers
        -- start          = "cursor"      -- start display from cursor?
        fzf_opts = {
          -- hide filename, tiebreak by line no.
          ['--delimiter'] = '[:]',
          ['--with-nth'] = '2..',
          ['--tiebreak'] = 'index',
          ['--tabstop'] = '1',
        },
        -- actions inherit from 'actions.buffers' and merge
        actions = {
          ['default'] = actions.buf_edit_or_qf,
          ['alt-q'] = actions.buf_sel_to_qf,
          ['alt-l'] = actions.buf_sel_to_ll,
        },
      },
      git = {
        branches = {
          prompt = '❯ ',
        },
      },
      lsp = {
        includeDeclaration = true, -- include current declaration in LSP context
        symbols = {
          fzf_opts = { ['--tiebreak'] = 'begin', ['--pointer'] = ' ' },
        },
      },
    }
  end,
}
