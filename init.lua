-- Mega Important!
vim.g.mapleader = " "
require("lazy-config")
require("plugin")
require("mapping")

-- some global stuff
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- Vim Basic Settings!
vim.opt.number = true
vim.opt.awa = true
vim.opt.showtabline = 0
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.showmode = false

-- CRITICAL FIX: Forces the gutter space to always be drawn, preventing code jumping
vim.opt.signcolumn = "yes" 

vim.opt.fillchars:append("eob: ")
vim.cmd("colorscheme jellybeans")
vim.opt.guicursor = "n-v-c:block"
vim.opt.termguicolors = true


-- ==========================================================================
-- Refactored Diagnostic Config & Custom Virtual Text Engine (Optimized)
-- ==========================================================================

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

local blink_timer = (vim.uv or vim.loop).new_timer()
local blink_state = true
local scroll_tick = 0 

-- HIGH-PERFORMANCE CACHES: Prevent querying Neovim's C-API in the hot loop
local buf_line_cache = {}
local str_width_cache = {}

local function get_str_width(str)
        if not str_width_cache[str] then
                str_width_cache[str] = vim.fn.strdisplaywidth(str)
        end
        return str_width_cache[str]
end

-- Safely trigger updates only for visible, valid buffers
local function safe_refresh_diagnostics()
        if vim.api.nvim_get_mode().mode == "i" then 
                return 
        end

        local current_buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_is_valid(current_buf) then
                vim.diagnostic.handlers.right_align.show(ns, current_buf, vim.diagnostic.get(current_buf), {})
        end
end

local function start_blink()
        blink_timer:start(
                0,
                250, 
                vim.schedule_wrap(function()
                        if scroll_tick % 4 == 0 then
                                blink_state = not blink_state
                        end
                        scroll_tick = scroll_tick + 1
                        safe_refresh_diagnostics()
                end)
        )
end

local function stop_blink()
        blink_timer:stop()
end

-- Custom right-aligned diagnostic handler
vim.diagnostic.handlers.right_align = {
        show = function(namespace, bufnr, diagnostics, _)
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

                if not diagnostics or #diagnostics == 0 or vim.api.nvim_get_mode().mode == "i" then 
                        return 
                end

                local win_id = vim.fn.bufwinid(bufnr)
                if win_id == -1 then return end

                local top_line = vim.fn.line("w0", win_id) - 1
                local bot_line = vim.fn.line("w$", win_id) - 1

                local grouped = {}
                for _, d in ipairs(diagnostics) do
                        local lnum = d.lnum
                        if lnum >= top_line and lnum <= bot_line then
                                grouped[lnum] = grouped[lnum] or {}
                                table.insert(grouped[lnum], d)
                        end
                end

                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local win_width = vim.api.nvim_win_get_width(win_id)
                local max_msg_width = math.floor(win_width * 0.33) 
                if max_msg_width < 10 then max_msg_width = 10 end 

                local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
                local cursor_line = cursor_pos[1] - 1 

                -- Buffer change tracker for invalidating the line text cache
                local b_tick = vim.api.nvim_buf_get_changedtick(bufnr)
                if not buf_line_cache[bufnr] or buf_line_cache[bufnr].tick ~= b_tick then
                        buf_line_cache[bufnr] = { tick = b_tick, lines = {} }
                end

                -- Sort lines to check for sequential duplicate messages
                local sorted_lnums = vim.tbl_keys(grouped)
                table.sort(sorted_lnums)

                local last_msg = nil
                local last_lnum = -2

                for _, lnum in ipairs(sorted_lnums) do
                        if lnum < line_count then
                                local diags = grouped[lnum]
                                local counts = { [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
                                local most_severe = diags[1]

                                for _, d in ipairs(diags) do
                                        counts[d.severity] = counts[d.severity] + 1
                                        if d.severity < most_severe.severity then
                                                most_severe = d
                                        end
                                end

                                -- CONT. LOGIC: Check if we should squash the error string
                                local raw_msg = most_severe.message
                                if raw_msg == last_msg and lnum == last_lnum + 1 then
                                        raw_msg = "(cont.)"
                                else
                                        last_msg = raw_msg
                                end
                                last_lnum = lnum

                                local prefix = ""
                                if blink_state then
                                        for severity = 1, 4 do
                                                if counts[severity] > 0 then
                                                        prefix = prefix .. string.rep(severity_symbols[severity], counts[severity])
                                                end
                                        end
                                end
                                prefix = prefix .. " "

                                -- OPTIMIZATION: Only calculate virtual text length if the line actually changed
                                local line_text_len = buf_line_cache[bufnr].lines[lnum]
                                if not line_text_len then
                                        local current_line_text = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                                        line_text_len = get_str_width(current_line_text)
                                        buf_line_cache[bufnr].lines[lnum] = line_text_len
                                end
                                
                                local allowed_width = max_msg_width
                                
                                if lnum == cursor_line then
                                        local clean_space = win_width - line_text_len - get_str_width(prefix) - 5
                                        if clean_space < allowed_width then
                                                allowed_width = math.max(5, clean_space) 
                                        end
                                end

                                local formatted_msg = "   " .. raw_msg .. "   "
                                local msg_len = #formatted_msg
                                local processed_msg = formatted_msg

                                if msg_len > allowed_width then
                                        local offset = scroll_tick % msg_len
                                        processed_msg = formatted_msg:sub(offset + 1) .. formatted_msg:sub(1, offset)
                                        processed_msg = processed_msg:sub(1, allowed_width)
                                else
                                        processed_msg = processed_msg .. string.rep(" ", allowed_width - msg_len)
                                end

                                local final_virtual_text = prefix .. processed_msg

                                local hl_group = ({
                                        [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
                                        [vim.diagnostic.severity.WARN]  = "DiagnosticWarnLine",
                                        [vim.diagnostic.severity.INFO]  = "DiagnosticInfoLine",
                                        [vim.diagnostic.severity.HINT]  = "DiagnosticHintLine",
                                })[most_severe.severity]

                                local virt_hl = ({ 
                                        [vim.diagnostic.severity.ERROR] = "DiagVirtError",
                                        [vim.diagnostic.severity.WARN]  = "DiagVirtWarn",
                                        [vim.diagnostic.severity.INFO]  = "DiagVirtInfo",
                                        [vim.diagnostic.severity.HINT]  = "DiagVirtHint",
                                })[most_severe.severity]

                                vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
                                        virt_text = { { final_virtual_text, virt_hl } },
                                        virt_text_pos = "right_align",
                                        hl_mode = "combine",
                                })

                                local end_col = most_severe.end_col or -1
                                vim.api.nvim_buf_add_highlight(bufnr, ns, hl_group, lnum, most_severe.col, end_col)
                        end
                end
        end,

        hide = function(namespace, bufnr)
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        end,
}

-- Master diagnostic setup activation
vim.diagnostic.config({
        virtual_text = false, 
        underline = false,
        signs = false,
        severity_sort = true,
        float = {
                border = "rounded",
                source = "always",
        },
        right_align = true, 
})

vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
                stop_blink()
                local buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
                scroll_tick = 0 
                start_blink()
                safe_refresh_diagnostics()
        end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
        callback = function()
                safe_refresh_diagnostics()
        end,
})

start_blink()

vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
                vim.diagnostic.open_float(nil, { focus = false })
        end,
})

-- ==========================================================================
-- LSP & Plugin Bootstrapping
-- ==========================================================================
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

require("lazy").setup("plugins")
