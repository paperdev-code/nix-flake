-- absolute lua magic courtesy of github.com/ingur
--

pcall(function() vim.loader.enable() end)

local pkgs_path = vim.fn.stdpath('data') .. '/site/'
local mini_path = pkgs_path .. 'pack/deps/start/mini.nvim'

require('mini.deps').setup({ path = { package = path_package } })
local now, later = MiniDeps.now, MiniDeps.later

now(function()
  local opt = vim.opt

  opt.autowrite = true

  if not vim.env.SSH_TTY then
    opt.clipboard = 'unnamedplus'
  end

  opt.completeopt = 'menu,menuone,noselect'
  opt.conceallevel = 0
  opt.confirm = true
  opt.cursorline = false
  opt.expandtab = true
  opt.mouse = 'a'
  opt.relativenumber = true
  opt.pumblend = 10
  opt.pumheight = 10
  opt.scrolloff = 4
  opt.shiftround = true
  opt.shiftwidth = 2
  opt.showmode = false
  opt.smartcase = true
  opt.smartindent = true
  opt.splitbelow = true
  opt.splitright = true
  opt.tabstop = 2
  opt.termguicolors = true
  opt.timeoutlen = 300
  opt.undofile = true
  opt.undolevels = 8000
  opt.updatetime = 200
  opt.virtualedit = 'block'
  opt.wildmode = 'longest:full,full'
  opt.winminwidth = 5
  opt.wrap = false

  for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
    vim.g['loaded_' .. provider .. '_provider'] = 0
  end

  vim.g.maplocalleader = ' '
  vim.g.mapleader = ' '
  vim.g.markdown_recommended_style = 0
end)

now(function()
  require("catppuccin").setup({
    background = {
      dark = "mocha",
    },
    transparent_background = true,
    color_overrides = {
      mocha = {
        rosewater = "#ea6962",
        flamingo = "#ea6962",
        pink = "#d3869b",
        mauve = "#d3869b",
        red = "#ea6962",
        maroon = "#ea6962",
        peach = "#e78a4e",
        yellow = "#d8a657",
        green = "#a9b665",
        teal = "#89b482",
        sky = "#89b482",
        sapphire = "#89b482",
        blue = "#7daea3",
        lavender = "#7daea3",
        text = "#ebdbb2",
        subtext1 = "#d5c4a1",
        subtext0 = "#bdae93",
        overlay2 = "#a89984",
        overlay1 = "#928374",
        overlay0 = "#595959",
        surface2 = "#4d4d4d",
        surface1 = "#404040",
        surface0 = "#292929",
        base = "#1d2021",
        mantle = "#191b1c",
        crust = "#141617",
      },
    },
    custom_highlights = function(colors)
      return {
        MiniStatuslineModeNormal = { bg = colors.blue, fg = colors.base },
        MiniStatuslineModeInsert = { bg = colors.green, fg = colors.base },
        MiniStatuslineModeCommand = { bg = colors.pink, fg = colors.base },
        MiniStatuslineModeVisual = { bg = colors.red, fg = colors.base },
        MiniStatuslineModeOther = { bg = colors.teal, fg = colors.base },
      }
    end,
  })
  vim.cmd("colorscheme catppuccin")
end)

local map = function(defaults)
  local config = vim.tbl_deep_extend("force", { mode = {}, prefix = "", opts = {} }, defaults)
  return function(lhs, rhs, desc, opts)
    lhs = config.prefix .. lhs
    opts = opts or {}
    if type(desc) == "table" then opts = desc else opts.desc = desc end
    opts = vim.tbl_deep_extend("force", config.opts, opts)
    vim.keymap.set(config.mode, lhs, rhs, opts)
  end
end

local nmap = map({ mode = "n" })
local imap = map({ mode = "i" })
local lmap = map({ mode = "n", prefix = "<leader>" })

now(function()
  require('mini.basics').setup({
    options = {
      basic = false,
    },
    mappings = {
      basic = true,
      windows = true,
      option_toggle_prefix = '<leader>t',
      move_with_alt = true,
    },
  })

  require('mini.misc').setup_auto_root({ '.git' })
  require('mini.misc').setup_restore_cursor()

  nmap(';', ':', 'Command')
  nmap('<C-c>', '<esc><cmd>q<cr>', 'Quit')
  imap('<C-c>', '<esc><cmd>q<cr>', 'Quit')
  lmap('qq', '<cmd>qa<cr>', 'Quit all')
end)

now(function()
  require('nvim-web-devicons').setup()
end)

now(function()
  require('mini.notify').setup({
    window = { winblend = 0, config = { border = 'rounded' } },
    lsp_progress = { enable = false },
  })
  vim.notify = require('mini.notify').make_notify()
end)

now(function()
  require('mini.statusline').setup({
    set_vim_settings = false,
  })
end)

now(function()
  require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = '<nop>',
        node_decremental = '<bs>',
      },
    },
  })
end)

now(function()
  local lspconfig = require('lspconfig')
  require('lspconfig.ui.windows').default_options.border = 'rounded'

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = 'rounded',
  })

  local icons = { Error = ' ', Warn = ' ', Hint = '󰌶 ', Info = ' ' }
  for name, icon in pairs(icons) do
    vim.fn.sign_define('DiagnosticSign' .. name, { text = icon, texthl = 'DiagnosticSign' .. name })
  end

  local function detect_bin(binary)
    return vim.fn.executable(binary) == 1
  end

  lspconfig.nil_ls.setup({})
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        completion = { keywordSnippet = 'Both', callSnippet = 'Disable' },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = {
          disable = { 'lowercase-global', 'undefined-global' },
        },
      },
    },
  })

  if detect_bin('zls') then
    lspconfig.zls.setup({})
    vim.g.zig_fmt_parse_errors = 0
  end
  if detect_bin('ruff') then
    lspconfig.ruff.setup({
      on_attach = function(_, buf)
        vim.api.nvim_buf_set_option(buf, 'tabstop', 2)
        vim.api.nvim_buf_set_option(buf, 'shiftwidth', 2)
        vim.api.nvim_buf_set_option(buf, 'expandtab', true)
      end
    })
  end
end)

later(function()
  local wk = require("which-key")
  wk.setup({
    win = {
      border = "rounded",
    },
  })

  wk.add({
    {
      mode = { "n", "v" },
      { "<leader>f", group = "file/find" },
      { "<leader>h", group = "hooks" },
      { "<leader>q", group = "quit/sessions" },
      { "<leader>t", group = "toggle" },
      { "[",         group = "prev" },
      { "]",         group = "next" },
      { "g",         group = "goto" },
    },
  })
end)

later(function()
  require("mini.cursorword").setup({})
  require("mini.bracketed").setup({})
  require("mini.splitjoin").setup({})
  require("mini.surround").setup({})
  require("mini.comment").setup({})
  require("mini.move").setup({})
  require("mini.jump").setup({ mappings = { repeat_jump = "" } })

  require("ibl").setup({
    indent = { tab_char = "│", char = "│", highlight = { "NonText" } },
    exclude = { filetypes = { "help", "starter" } },
    scope = { enabled = false },
  })

  require("mini.bufremove").setup({})
  lmap("qw", function() MiniBufremove.delete() end, "Delete buffer")
  lmap("qW", function() MiniBufremove.delete(0, true) end, "Delete buffer (force)")

  local persistence = require("persistence")
  persistence.setup({})
  lmap("qs", function() persistence.load() end, "Restore session (cwd)")
  lmap("qS", function() persistence.load({ last = true }) end, "Restore last session")
end)

later(function()
  require("toggleterm").setup({
    shade_terminals = false,
    open_mapping = nil,
    persist_mode = false,
    float_opts = { border = "rounded" },
    size = function(term)
      if term.direction == "horizontal" then
        return 8
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.25
      end
    end,
  })

  local direction = "horizontal"
  local toggle_term = function() vim.cmd(string.format('execute v:count . "ToggleTerm direction=%s"', direction)) end
  local toggle_direction = function()
    local visible = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if string.find(vim.fn.bufname(buf), "^term://") then visible = true end
    end
    if visible then toggle_term() end
    direction = direction == "vertical" and "horizontal" or "vertical"
    if visible then toggle_term() end
  end

  local bmap = function(t, lhs, rhs)
    vim.keymap.set("t", lhs, rhs, { noremap = true, silent = true, buffer = t.bufnr })
  end
  local term = require("toggleterm.terminal").Terminal
  local lazygits = {}
  local idx = 1337

  local toggle_lazygit = function()
    local cwd = vim.fn.getcwd()
    if not lazygits[cwd] then
      lazygits[cwd] = term:new({
        cmd = "lazygit",
        count = idx,
        hidden = true,
        direction = "float",
        on_open = function(t)
          bmap(t, "<esc>", "<esc>")
          bmap(t, "<C-g>", function() _G._toggle_lazygit() end)
          bmap(t, "<C-t>", function() toggle_term() end)
        end,
      })
      idx = idx + 1
    end
    lazygits[cwd]:toggle()
  end
  _G._toggle_lazygit = toggle_lazygit

  local nimap = map({ mode = { "n", "i" } })
  nimap("<C-t>", function() toggle_term() end, "Toggle terminal")
  nimap("<C-g>", function() toggle_lazygit() end, "Toggle lazygit")
  lmap("tt", function() toggle_direction() end, "Toggle terminal direction")

  local tmap = map({ mode = "t" })
  tmap("<C-t>", function() toggle_term() end, "Toggle terminal")
  tmap("<esc>", "<C-\\><C-n>", "Normal mode")
  tmap("<C-j>", "<C-\\><C-n><C-w>j", "Move to left window")
  tmap("<C-k>", "<C-\\><C-n><C-w>k", "Move to bottom window")
  tmap("<C-h>", "<C-\\><C-n><C-w>h", "Move to top window")
  tmap("<C-l>", "<C-\\><C-n><C-w>l", "Move to right window")
  tmap("<C-Up>", "<C-\\><C-n><cmd>resize -2<cr>", "Resize window up")
  tmap("<C-Down>", "<C-\\><C-n><cmd>resize +2<cr>", "Resize window down")
  tmap("<C-Left>", "<C-\\><C-n><cmd>vertical resize -2<cr>", "Resize window left")
  tmap("<C-Right>", "<C-\\><C-n><cmd>vertical resize +2<cr>", "Resize window right")
end)

later(function()
  local function augroup(name) return vim.api.nvim_create_augroup("custom_" .. name, { clear = true }) end

  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    command = "checktime",
  })

  vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function() vim.cmd("tabdo wincmd =") end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
      "help",
      "lspinfo",
      "man",
      "notify",
      "qf",
      "query",
      "startuptime",
    },

    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })
end)
