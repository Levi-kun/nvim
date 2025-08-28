-- Most important the leader!

local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<leader>5", function()
	harpoon:list():select(5)
end, { noremap = true, silent = true })
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>ws", builtin.current_buffer_fuzzy_find)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)
local a = 2
print(a)
-- Change working directory.

vim.keymap.set("n", "<leader>cd", function()
	vim.cmd("cd %:p:h")
	builtin.find_files()
end, { desc = "Set Directory!" })

-- Change themes!

vim.keymap.set("n", "<leader>th", ":Themery<CR>", { desc = "Switch theme" })

-- Moving between buffers!
vim.keymap.set("n", "<leader><left>", "<C-W><left>")
vim.keymap.set("n", "<leader><right>", "<C-W><right>")

vim.keymap.set("n", "<leader>/<up>", ":move  .-2<CR>==")
vim.keymap.set("n", "<leader>/<down>", ":move .+1<CR>==")

local ts = require("telescope").load_extension("emoji")
vim.keymap.set("n", "<leader>se", ts.emoji, { desc = "[S]earch [E]moji" })

vim.keymap.set("t", "<leader>e", "<C-\\><C-n>")

-- Let's quit nvim! ... no one quits nvim, forever
vim.keymap.set("n", "<leader>aQ", ":quitall<CR>")
