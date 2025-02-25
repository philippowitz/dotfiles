local map = vim.keymap.set

vim.opt.hlsearch = true
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Add empty lines before and after cursor line
map('n', 'gO', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
map('n', 'go', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

map({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<CR>', { desc = 'File Save' })

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>E', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<leader>q', '<cmd> lua require("fzf-lua").quickfix() <CR>', { desc = 'Open diagnostic [Q]uickfix list' })

-- map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--FZF
map('n', '<leader>sh', function()
  require('fzf-lua').help_tags()
end, { desc = '[S]earch [H]elp' })
map('n', '<leader>ff', function()
  require('fzf-lua').files()
end, { desc = '[F]ind [F]iles' })
map('n', '<leader>sk', function()
  require('fzf-lua').keymaps()
end, { desc = '[S]earch [K]eymaps' })
map('n', '<leader>sB', function()
  require('fzf-lua').builtin()
end, { desc = '[S]earch [B]uiltins' })
map('n', '<leader>sw', function()
  require('fzf-lua').grep_cword()
end, { desc = '[S]earch current [W]ord' })
map('n', '<leader>sg', function()
  require('fzf-lua').live_grep_native()
end, { desc = '[S]earch by [G]rep' })
map('n', '<leader>sd', function()
  require('fzf-lua').diagnostics()
end, { desc = '[S]earch [D]iagnostics' })
map('n', '<leader>sr', function()
  require('fzf-lua').resume()
end, { desc = '[S]earch [R]esume' })
map('n', '<leader>fr', function()
  require('fzf-lua').oldfiles()
end, { desc = '[F]ind [R]ecent Files' })
map('n', '<leader><leader>', function()
  require('fzf-lua').buffers()
end, { desc = '[ ] Find Existing Buffers' })

map('n', '<leader>/', function()
  require('fzf-lua').lgrep_curbuf()
end, { desc = '[/] Fuzzily search in current buffer' })

map('n', '<leader>s/', function()
  require('fzf-lua').live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[S]earch [/] in Open Files' })
map('n', '<leader>fn', function()
  require('fzf-lua').files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[F]ind [N]eovim files' })

--autosave
map('n', '<leader>n', ':ASToggle<CR>', {})

map('n', '<leader>gg', function()
  require('neogit').open()
end, { silent = true, noremap = true })
map('n', '<leader>gc', function()
  require('neogit').open { 'commit' }
end, { silent = true, noremap = true })
map('n', '<leader>gp', function()
  require('neogit').open { 'pull' }
end, { silent = true, noremap = true })
map('n', '<leader>gP', function()
  require('neogit').open { 'push' }
end, { silent = true, noremap = true })
map('n', '<leader>gb', function()
  require('fzf-lua').git_branches()
end, { silent = true, noremap = true })
-- map('n', '<leader>gB', ':G blame<CR>', { silent = true, noremap = true })

-- smart splits
map('n', '<A-h>', function()
  require('smart-splits').resize_left()
end)
map('n', '<A-j>', function()
  require('smart-splits').resize_down()
end)
map('n', '<A-k>', function()
  require('smart-splits').resize_up()
end)
map('n', '<A-l>', function()
  require('smart-splits').resize_right()
end)
-- moving between splits
map('n', '<C-h>', function()
  require('smart-splits').move_cursor_left()
end)
map('n', '<C-j>', function()
  require('smart-splits').move_cursor_down()
end)
map('n', '<C-k>', function()
  require('smart-splits').move_cursor_up()
end)
map('n', '<C-l>', function()
  require('smart-splits').move_cursor_right()
end)
map('n', '<C-\\>', function()
  require('smart-splits').move_cursor_previous()
end)
-- swapping buffers between windows
map('n', '<leader><C-w>h', function()
  require('smart-splits').swap_buf_left()
end)
map('n', '<leader><C-w>j', function()
  require('smart-splits').swap_buf_down()
end)
map('n', '<leader><C-w>k', function()
  require('smart-splits').swap_buf_up()
end)
map('n', '<leader><C-w>l', function()
  require('smart-splits').swap_buf_right()
end)

-- vim: ts=2 sts=2 sw=2 et
