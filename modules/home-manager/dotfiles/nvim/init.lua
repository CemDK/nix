-- Basic options
vim.opt.inccommand = "split"
vim.opt.scrolloff = 8

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = false

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.wrap = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI elements
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.termguicolors = true

-- Leader key
vim.g.mapleader = " "

-- Load keymaps
require('config.keymaps')

-- Bootstrap plugin manager (packer)
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Load plugins
require('plugins')

-- Colorscheme
-- require('solarized').setup({ 
--   transparent = true, 
--   palette = 'solarized' 
-- })
-- vim.cmd('colorscheme solarized')