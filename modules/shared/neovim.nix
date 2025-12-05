{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Dependencies
      plenary-nvim

      # Theme/UI
      tokyonight-nvim
      lualine-nvim
      nvim-web-devicons

      # File navigation
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-tree-lua

      # LSP & Completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # Treesitter
      (nvim-treesitter.withPlugins (p: [
        p.nix p.lua p.python p.typescript p.javascript
        p.json p.yaml p.toml p.markdown p.bash
        p.html p.css p.tsx p.vim p.vimdoc
      ]))

      # Editing
      comment-nvim
      nvim-autopairs
      gitsigns-nvim
      vim-tmux-navigator
      which-key-nvim
    ];

    extraPackages = with pkgs; [
      # Language servers
      nil
      nodePackages.typescript-language-server
      pyright
      lua-language-server

      # Tools for telescope
      ripgrep
      fd
    ];

    extraLuaConfig = ''
      -- Leader key (MUST be set before plugins)
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Basic Options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = "a"
      vim.opt.showmode = false
      vim.opt.clipboard = "unnamedplus"
      vim.opt.breakindent = true
      vim.opt.undofile = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.cursorline = true
      vim.opt.scrolloff = 3
      vim.opt.wrap = false
      vim.opt.hidden = true

      -- Indentation
      vim.opt.tabstop = 8
      vim.opt.shiftwidth = 2
      vim.opt.softtabstop = 2
      vim.opt.expandtab = true

      -- Search
      vim.opt.hlsearch = true
      vim.opt.incsearch = true

      -- No backup/swap
      vim.opt.backup = false
      vim.opt.writebackup = false
      vim.opt.swapfile = false

      -- Delete without yanking (leader prefix)
      vim.keymap.set({"n", "v"}, "<leader>d", '"_d', { desc = "Delete without yanking" })
      vim.keymap.set({"n", "v"}, "<leader>D", '"_D', { desc = "Delete to end without yanking" })
      vim.keymap.set({"n", "v"}, "<leader>c", '"_c', { desc = "Change without yanking" })
      vim.keymap.set({"n", "v"}, "<leader>C", '"_C', { desc = "Change to end without yanking" })
      vim.keymap.set("n", "<leader>x", '"_x', { desc = "Delete char without yanking" })

      -- Window navigation
      vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
      vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
      vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
      vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

      -- Buffer navigation
      vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer", silent = true })
      vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer", silent = true })

      -- Quit window
      vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })

      -- Yank to end of line
      vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

      -- Clipboard operations
      vim.keymap.set("n", "<leader>p", '"+gP', { desc = "Paste from clipboard" })
      vim.keymap.set("x", "<leader>y", '"+y', { desc = "Copy to clipboard" })

      -- Move by display lines when wrapping
      vim.keymap.set("n", "j", "gj", { silent = true })
      vim.keymap.set("n", "k", "gk", { silent = true })

      -- Clear search highlight
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

      -- Theme
      vim.cmd.colorscheme("tokyonight-night")

      -- Lualine
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })

      -- Telescope
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
      })
      pcall(require("telescope").load_extension, "fzf")

      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", require("telescope.builtin").oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader><leader>", require("telescope.builtin").find_files, { desc = "Find files" })

      -- Nvim-tree
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })

      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer", silent = true })
      vim.keymap.set("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus file explorer", silent = true })

      -- LSP Configuration
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- TypeScript
      lspconfig.ts_ls.setup({ capabilities = capabilities })

      -- Nix
      lspconfig.nil_ls.setup({ capabilities = capabilities })

      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- LSP Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- Treesitter
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- Completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })

      -- Comment
      require("Comment").setup()

      -- Autopairs
      require("nvim-autopairs").setup()

      -- Gitsigns
      require("gitsigns").setup()

      -- Which-key
      require("which-key").setup()
    '';
  };
}
