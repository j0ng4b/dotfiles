local config = function()
    local hop = require("hop")
    hop.setup({
        keys = "etovxqpdygfblzhckisuran",
        uppercase_labels = false,
    })

    vim.keymap.set({ "n", "v" }, "s", "<Cmd>HopChar2AC<CR>", { desc = "Hop to bigram after cursor" })
    vim.keymap.set({ "n", "v" }, "S", "<Cmd>HopChar2BC<CR>", { desc = "Hop to bigram before cursor" })
    vim.keymap.set({ "n", "v" }, ";w", "<Cmd>HopWord<CR>", { desc = "Hop to word in current buffer" })
    vim.keymap.set({ "n", "v" }, ";c", "<Cmd>HopCamelCaseMW<CR>", { desc = "Hop to camelCase word" })
    vim.keymap.set({ "n", "v" }, ";d", "<Cmd>HopLineStart<CR>", { desc = "Hop to line" })
    vim.keymap.set({ "n", "v" }, ";f", "<Cmd>HopNodes<CR>", { desc = "Hop to node" })
    vim.keymap.set({ "n", "v" }, ";s", "<Cmd>HopPatternMW<CR>", { desc = "Hop to pattern" })
    vim.keymap.set({ "n", "v" }, ";j", "<Cmd>HopVertical<CR>", { desc = "Hop to location vertically" })

    local directions = require("hop.hint").HintDirection
    vim.keymap.set("", "f", function()
        hop.hint_char1({
            direction = directions.AFTER_CURSOR,
            current_line_only = true,
        })
    end, { remap = true })

    vim.keymap.set("", "F", function()
        hop.hint_char1({
            direction = directions.BEFORE_CURSOR,
            current_line_only = true,
        })
    end, { remap = true })

    vim.keymap.set("", "t", function()
        hop.hint_char1({
            direction = directions.AFTER_CURSOR,
            current_line_only = true,
            hint_offset = -1,
        })
    end, { remap = true })

    vim.keymap.set("", "T", function()
        hop.hint_char1({
            direction = directions.BEFORE_CURSOR,
            current_line_only = true,
            hint_offset = 1,
        })
    end, { remap = true })
end

return {
    "smoka7/hop.nvim",
    config = config,
}
