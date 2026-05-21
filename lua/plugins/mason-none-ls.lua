return {
	"jay-babu/mason-null-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"nvimtools/none-ls.nvim",
	},
        config = function()
                require("mason-null-ls").setup({
                      ensure_installed = { "prettierd", "black", "stylua", "eslint_d", "ruff" },
                      handlers = {},
                      automatic_installation = true,
                })
        end,
}
