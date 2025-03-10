-- ~/.config/nvim/init.lua
-- Pure Neovim Lua implementation with modern alternatives

-- === Leader must be set first ===
vim.g.mapleader = ' '

-- === Basic Settings ===
vim.opt.compatible = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.updatetime = 100

-- === Plugin Management (lazy.nvim) ===
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- File Explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- LSP & Completion
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
  },

  -- Git Integration
  { 'tpope/vim-fugitive' },
  { 'lewis6991/gitsigns.nvim' },

  -- Syntax & Language Support
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  -- Utilities
  { 'numToStr/Comment.nvim' },       -- Comment toggling
  { 'windwp/nvim-autopairs' },       -- Auto pairs
  { 'kylechui/nvim-surround' },      -- Surround text objects
  { 'mbbill/undotree' },             -- Visual undo history
  { 'goolord/alpha-nvim' },          -- Start screen

  -- Themes
  { 'nordtheme/vim' },               -- Nord theme
  { 'ellisonleao/gruvbox.nvim' },    -- Gruvbox
  { 'dracula/vim', as = 'dracula' },
})

-- === Plugin Configurations ===

-- Nvim-Tree (file explorer)
require('nvim-tree').setup({
  filters = { dotfiles = false },
  renderer = { group_empty = true },
})
vim.keymap.set('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<C-f>', '<cmd>NvimTreeFindFile<CR>')

-- Lualine (statusline)
require('lualine').setup({
  options = { theme = 'dracula' },
  extensions = { 'nvim-tree' },
})

-- Telescope (fuzzy finder)
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope.find_files)
vim.keymap.set('n', '<leader>b', telescope.buffers)
vim.keymap.set('n', '<leader>rg', telescope.live_grep)

-- LSP & Completion
local lsp = require('lspconfig')
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
end

-- Configure LSP servers
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'tsserver', 'rust_analyzer' },
  handlers = {
    function(server_name)
      lsp[server_name].setup({ on_attach = on_attach })
    end,
  }
})

-- Treesitter (syntax highlighting)
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'javascript', 'typescript', 'lua', 'python' },
  highlight = { enable = true },
})

-- Git Signs
require('gitsigns').setup()

-- Comment.nvim
require('Comment').setup()

-- Autopairs
require('nvim-autopairs').setup()

-- Surround
require('nvim-surround').setup()

-- Undotree
vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>')

-- Alpha (start screen)
require('alpha').setup(require('alpha.themes.startify').config)

-- === Key Bindings ===
-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Buffer management
vim.keymap.set('n', '<leader>q', '<cmd>bd<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')

-- Clear search highlights
vim.keymap.set('n', '<leader>c', '<cmd>nohl<CR>')

-- === Auto Commands ===
local group = vim.api.nvim_create_augroup('autosourcing', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  group = group,
  pattern = 'init.lua',
  callback = function() vim.cmd('source %') end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- === Theme ===
vim.cmd.colorscheme('dracula')
vim.opt.background = 'dark'

-- === Terminal Integration ===
vim.keymap.set('t', 'jj', [[<C-\><C-n>]])  -- Escape terminal mode
