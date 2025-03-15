vim.g.mapleader = ' '
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
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

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

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  { 'numToStr/Comment.nvim' },
  { 'windwp/nvim-autopairs' },
  { 'kylechui/nvim-surround' },
  { 'mbbill/undotree' },
  { 'goolord/alpha-nvim' },

  { 'nordtheme/vim' },
  { 'ellisonleao/gruvbox.nvim' },
  { 'dracula/vim', as = 'dracula' },
})

require('nvim-tree').setup({
  filters = { dotfiles = false },
  renderer = { group_empty = true },
})
vim.keymap.set('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<C-f>', '<cmd>NvimTreeFindFile<CR>')

require('lualine').setup({
  options = { theme = 'dracula' },
  extensions = { 'nvim-tree' },
})

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope.find_files)
vim.keymap.set('n', '<leader>b', telescope.buffers)
vim.keymap.set('n', '<leader>rg', telescope.live_grep)

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

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'rust_analyzer' },
  handlers = {
    function(server_name)
      lsp[server_name].setup({ on_attach = on_attach })
    end,
  }
})

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'javascript', 'typescript', 'lua', 'python' },
  highlight = { enable = true },
})

require('Comment').setup()

require('nvim-autopairs').setup()

require('nvim-surround').setup()

vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>')

require('alpha').setup(require('alpha.themes.startify').config)

vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.keymap.set('n', '<leader>q', '<cmd>bd<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')

vim.keymap.set('n', '<leader>c', '<cmd>nohl<CR>')

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

vim.cmd.colorscheme('dracula')
vim.opt.background = 'dark'

vim.keymap.set('t', 'jj', [[<C-\><C-n>]])
vim.keymap.set("i", "jj", "<Esc>")
