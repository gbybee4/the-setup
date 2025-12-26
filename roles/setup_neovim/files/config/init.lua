-- Disable netrw (for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
opt.termguicolors = true
opt.signcolumn = "yes"
opt.list = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99

-- =========================
-- Autocommands
-- =========================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    local dir = vim.fn.fnamemodify(args.file, ":p:h")
    if dir ~= "" then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- =========================
-- Key mappings
-- =========================
vim.g.mapleader = " "
local map = vim.keymap.set

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })

map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without overwriting clipboard" })

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Quick run
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
-- Plugins
-- =========================
require("lazy").setup({
  {
    "dracula/vim",
    name = "dracula",
    config = function()
      vim.cmd("colorscheme dracula")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      -- Fix poor contrast in bufferline
      local dracula_foreground = "#f8f8f2"
      local dracula_comment = "#6272a4"
      vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = dracula_foreground })
      vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = dracula_comment })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = "dracula",
          globalstatus = true,
        },
        sections = {
          lualine_x = { "encoding" },
          lualine_y = { "filetype" },
        },
      })
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
    "zbirenbaum/copilot.lua",
    lazy = false,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = false,
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      map("i", "<Tab>", function()
        if require("copilot.suggestion").is_visible() then
          return require("copilot.suggestion").accept()
        end
      end, { expr = true, silent = true, desc = "Accept Copilot suggestion" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.load_extension("fzf")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
      map("n", "<C-h>", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })
      map("n", "<C-l>", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
      map("n", "<C-q>", "<cmd>BufferClose<cr>", { desc = "Close buffer" })
      map("n", "<C-p>", "<cmd>BufferPick<cr>", { desc = "Pick buffer" })
      for i = 1, 9 do
        map("n", "<A-" .. i .. ">", "<cmd>BufferGoto " .. i .. "<cr>", { desc = "Go to buffer " .. i })
      end
    end,
    opts = {
      auto_hide = true,
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
    init = function()
      vim.opt.undofile = true
      local undodir = vim.fn.stdpath("data") .. "/undo"
      if vim.fn.isdirectory(undodir) == 0 then
        vim.fn.mkdir(undodir, "p")
      end
      vim.opt.undodir = undodir
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },
})
