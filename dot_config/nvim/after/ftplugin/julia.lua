vim.keymap.set({ 'x' }, '<CR>', '<Plug>SlimeRegionSend', { desc = 'Slime Send Selection', buffer = 0 })
vim.keymap.set({ 'n' }, '<CR>', '<Plug>SlimeLineSend', { desc = 'Slime Send Line', buffer = 0 })
vim.keymap.set({ 'n' }, '<CR>', '<Plug>SlimeLineSend<CR>', { desc = 'Slime Send Line', buffer = 0 })
-- vim.keymap.set({ 'x' }, '<CR>', '<Plug>SlimeRegionSend', { desc = 'File Save', buffer = 0 })
