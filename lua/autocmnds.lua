local harpoon = require("harpoon")
local mark = require("harpoon.mark")

function AddFileToHarpoon()
    -- Get the list of marked files
    local marks = harpoon.get_marked_file(1)  -- Get the first marked file to check the count
    local manual_count = 0

    -- Count the number of manual harpoons (excluding the terminal)
    for i = 1, #marks do
        if marks[i] and marks[i].name ~= nil and marks[i].name ~= "" then
            manual_count = manual_count + 1
        end
    end

    -- Check if there are already 4 manual harpoons
    if manual_count < 4 then
        mark.add_file()  -- Add the current file to Harpoon
    else
        print("Maximum of 4 manual harpoons reached. Please remove one before adding another.")
    end
end

function AddTerminalToHarpoon()
    -- Check if the current buffer is a terminal
    if vim.bo.filetype == "terminal" then
        mark.add_file()  -- Add the terminal buffer to Harpoon
        -- Set the terminal to the fifth slot
        harpoon.get_marked_file(5).name = vim.fn.expand('%:p')  -- Update the fifth slot with the terminal path
    end
end

-- Auto Commands

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        AddTerminalToHarpoon()
    end,
})

vim.api.nvim_create_user_command('HarpoonAdd', AddFileToHarpoon, {})
