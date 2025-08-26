-- Mega Important!
vim.g.mapleader = " "
require("lazy-config")
require("plugin")
require("mapping")

-- some global stuff
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- Vim Basic Settings!
vim.diagnostic.config({ virtual_text = true })
vim.opt.number = true
vim.opt.awa = true
vim.opt.showtabline = 0
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.undofile = true
vim.opt.cursorline = true

-- Nvim themes!
require('smear_cursor').setup({
        cursor_color = '#FFFFFF',
        smear_between_buffers = false,
        scroll_buffer_space = true,
        smear_between_neighbor_lines = true,
        stiffness = 0.5,
        trailing_stiffness = 0.5,
        matrix_pixel_threshold = 0.5,
})
vim.cmd("colorscheme jellybeans")
vim.opt.guicursor = "n-v-c:block"

-- Cursor line = pure black (#000000)
vim.cmd([[
  highlight CursorLine cterm=NONE ctermbg=Black guibg=#000000
]])

vim.opt.termguicolors = true

-- Lsp server!
require("mason").setup()
require("mason-lspconfig").setup({
	automatic_enable = true,
	ensure_installed = { "lua_ls", "ts_ls" },
})
require("null-ls").setup({
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
require("mason-null-ls").setup({
	ensure_installed = { "prettierd", "black", "stylua", "eslint_d", "ruff" },
	handlers = {},
	automatic_installation = true,
})
local function load_configs()
	require("config.lua-line")
	require("config.nvim-tree")
	require("config.treesitter")
end

load_configs()
