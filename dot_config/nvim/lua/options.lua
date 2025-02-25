local opt = vim.opt

opt.number = true

opt.relativenumber = true

opt.laststatus = 3

opt.mouse = 'a'

opt.showmode = false

opt.clipboard = 'unnamedplus'

opt.breakindent = true

opt.undofile = true

opt.undolevels = 1000
opt.undoreload = 10000

opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 200

opt.timeoutlen = 200

opt.splitright = true
opt.splitbelow = true

opt.list = true
opt.linebreak = true
opt.listchars = { tab = '» ', trail = '·', nbsp = ' ̺' }

opt.inccommand = 'split'

opt.conceallevel = 1

opt.cursorline = true

opt.scrolloff = 10

opt.shortmess:append 'sI'

opt.whichwrap:append '<>[]hl'

opt.backup = true

opt.shada = "!,h,'1000,<1000,s128,/1000,:1000,@1000"

opt.backupdir = vim.fn.expand '~/.local/state' .. '/nvim/backup'

opt.directory = vim.fn.expand '~/.local/state' .. '/nvim/tmp'

opt.undodir = vim.fn.expand '~/.local/state' .. '/nvim/undo'

vim.filetype.add { extension = { typ = 'typst' } }

vim.diagnostic.config { virtual_text = false, severity_sort = true }
