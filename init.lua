-- Mega Important!
vim.g.mapleader = " "
require("lazy-config")
require("plugin")
require("mapping")

-- some global stuff
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- Vim Basic Settings!
vim.diagnostic.config({ virtual_text = false }) -- this is just so I know it is turned on, for some reason the default is disabled..

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.awa = true
vim.opt.showtabline = 0
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.showmode = false

vim.opt.fillchars:append("eob: ")
vim.cmd("colorscheme jellybeans")
vim.opt.guicursor = "n-v-c:block"

vim.opt.termguicolors = true

-- Nvim themes!
require("smear_cursor").setup({
        cursor_color = "#FFFFFF",
        smear_between_buffers = true,
        scroll_buffer_space = true,
        smear_between_neighbor_lines = true,
        stiffness = 0.30,
        trailing_stiffness = 0.15,
        matrix_pixel_threshold = 0.85,
})

-- Diagnoistic config!

vim.diagnostic.config({
        virtual_text = false,
        underline = false,
        signs = false,
        severity_sort = true,
        float = {
                border = "rounded",
                source = "always",
        },
})

-- Highlight entire code ranges
vim.api.nvim_set_hl(0, "DiagnosticErrorLine", { bg = "#550000" })
vim.api.nvim_set_hl(0, "DiagnosticWarnLine", { bg = "#553300" })
vim.api.nvim_set_hl(0, "DiagnosticInfoLine", { bg = "#003355" })
vim.api.nvim_set_hl(0, "DiagnosticHintLine", { bg = "#224422" })

-- Bold highlight groups for virtual text
vim.api.nvim_set_hl(0, "DiagVirtError", { bg = "#550000", bold = true })
vim.api.nvim_set_hl(0, "DiagVirtWarn", { bg = "#553300", bold = true })
vim.api.nvim_set_hl(0, "DiagVirtInfo", { bg = "#003355", bold = true })
vim.api.nvim_set_hl(0, "DiagVirtHint", { bg = "#224422", bold = true })

local ns = vim.api.nvim_create_namespace("right_align_diagnostics")

local severity_symbols = {
        [vim.diagnostic.severity.ERROR] = "❌",
        [vim.diagnostic.severity.WARN] = "⚠️",
        [vim.diagnostic.severity.INFO] = "ℹ️",
        [vim.diagnostic.severity.HINT] = "💡",
}

local blink_timer = vim.loop.new_timer()
local blink_state = true

-- start blinking
local function start_blink()
        blink_timer:start(
                0,
                1900,
                vim.schedule_wrap(function()
                        blink_state = not blink_state
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                if vim.api.nvim_buf_is_loaded(buf) then
                                        vim.diagnostic.handlers.right_align.show(nil, buf, vim.diagnostic.get(buf), {})
                                end
                        end
                end)
        )
end

-- stop blinking
local function stop_blink()
        blink_timer:stop()
end

vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
                stop_blink()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
                end
        end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
                start_blink()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf) then
                                vim.diagnostic.handlers.right_align.show(nil, buf, vim.diagnostic.get(buf), {})
                        end
                end
        end,
})

-- make sure blinking starts initially
start_blink()

vim.diagnostic.handlers.right_align = {
        show = function(_, bufnr, diagnostics, _)
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

                -- group diagnostics by line
                local grouped = {}
                for _, d in ipairs(diagnostics) do
                        local lnum = d.lnum
                        grouped[lnum] = grouped[lnum] or {}
                        table.insert(grouped[lnum], d)
                end

                for lnum, diags in pairs(grouped) do
                        -- count per severity
                        local counts = { [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
                        local most_severe = diags[1]

                        for _, d in ipairs(diags) do
                                counts[d.severity] = counts[d.severity] + 1
                                if d.severity < most_severe.severity then
                                        most_severe = d
                                end
                        end

                        -- build prefix string
                        local prefix = ""
                        if blink_state then
                                for severity = 1, 4 do -- ERROR=1, WARN=2, INFO=3, HINT=4
                                        if counts[severity] > 0 then
                                                prefix = prefix ..
                                                string.rep(severity_symbols[severity], counts[severity])
                                        end
                                end
                        end

                        local hl_group = ({
                                [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
                                [vim.diagnostic.severity.WARN] = "DiagnosticWarnLine",
                                [vim.diagnostic.severity.INFO] = "DiagnosticInfoLine",
                                [vim.diagnostic.severity.HINT] = "DiagnosticHintLine",
                        })[most_severe.severity]

                        local virt_hl = ({
                                [vim.diagnostic.severity.ERROR] = "DiagVirtError",
                                [vim.diagnostic.severity.WARN] = "DiagVirtWarn",
                                [vim.diagnostic.severity.INFO] = "DiagVirtInfo",
                                [vim.diagnostic.severity.HINT] = "DiagVirtHint",
                        })[most_severe.severity]

                        -- final message: prefix + padding + message
                        local message = prefix .. "   " .. most_severe.message .. "   "

                        -- right-align virtual text with highlight
                        if lnum < vim.api.nvim_buf_line_count(bufnr) then
                                vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, -1, {
                                        virt_text = { { message, virt_hl } },
                                        virt_text_pos = "right_align",
                                })
                        end

                        -- highlight full range
                        vim.api.nvim_buf_add_highlight(bufnr, ns, hl_group, lnum, most_severe.col,
                                most_severe.end_col or -1)
                end
        end,

        hide = function(_, bufnr)
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        end,
}

-- Refresh diagnostics
vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function(args)
                vim.diagnostic.handlers.right_align.show(nil, args.buf, vim.diagnostic.get(args.buf), {})
        end,
})

-- Cursor hover shows full diagnostic list
vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
                vim.diagnostic.open_float(nil, { focus = false })
        end,
})

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
        require("config.autocomplete")
end

load_configs()
