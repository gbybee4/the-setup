-- =========================
-- Options
-- =========================
local opt = vim.opt

opt.relativenumber = true
opt.smartindent = true
opt.smartcase = true
opt.incsearch = true
opt.showmatch = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- =========================
-- Autocommands
-- =========================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
  end,
})

-- =========================
-- Key mappings
-- =========================
local map = vim.keymap.set

map("n", "<F2>", function()
  vim.cmd("w")
  vim.fn.jobstart("quick-run-go")
end, { silent = true })

map("i", "<F2>", function()
  vim.cmd("stopinsert")
  vim.cmd("w")
  vim.fn.jobstart("quick-run-go")
end, { silent = true })

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugin specs
-- =========================
require("lazy").setup({
  {
    "dracula/vim",
    name = "dracula",
    config = function()
      vim.cmd("colorscheme dracula")
      vim.cmd("hi Normal ctermbg=NONE")
    end,
  },
  {
    "vim-airline/vim-airline",
    dependencies = {
      "vim-airline/vim-airline-themes",
    },
    init = function()
      vim.g.airline_theme = "dracula"
    end,
  },
  {
    "tpope/vim-commentary",
    keys = { "gc", "gcc" },
  },
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },
})

