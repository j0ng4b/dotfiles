return {
    "smoka7/hop.nvim",
    config = function()
        local hop = require("hop")
        local directions = require("hop.hint").HintDirection

        hop.setup({
            keys = "asdghklqwertyuiopzxcvbnmfj",
            uppercase_labels = false,

            excluded_filetypes = {
                "neo-tree",
            },
        })

        local function map(modes, lhs, rhs, desc)
            vim.keymap.set(modes, lhs, rhs, {
                silent = true,
                desc = desc,
            })
        end

        map({ "n", "x" }, "s", "<Cmd>HopChar2AC<CR>", "hop to bigram after cursor")
        map({ "n", "x" }, "S", "<Cmd>HopChar2BC<CR>", "hop to bigram before cursor")
        map({ "n", "x" }, ";w", "<Cmd>HopWord<CR>", "hop to word")
        map({ "n", "x" }, ";c", "<Cmd>HopCamelCase<CR>", "hop to camelCase word")
        map({ "n", "x" }, ";d", "<Cmd>HopLineStart<CR>", "hop to line")
        map({ "n", "x" }, ";f", "<Cmd>HopNodes<CR>", "hop to node")
        map({ "n", "x" }, ";s", "<Cmd>HopPattern<CR>", "hop to pattern")
        map({ "n", "x" }, ";j", "<Cmd>HopVertical<CR>", "hop to location vertically")

        map({ "" }, "f", function()
            hop.hint_char1({
                direction = directions.AFTER_CURSOR,
                current_line_only = true,
            })
        end, "hop to occurrence of char to the right")

        map({ "" }, "F", function()
            hop.hint_char1({
                direction = directions.BEFORE_CURSOR,
                current_line_only = true,
            })
        end, "hop to occurrence of char to the left")

        map({ "" }, "t", function()
            hop.hint_char1({
                direction = directions.AFTER_CURSOR,
                current_line_only = true,
                hint_offset = -1,
            })
        end, "hop till before occurrence of char to the right")

        map({ "" }, "T", function()
            hop.hint_char1({
                direction = directions.BEFORE_CURSOR,
                current_line_only = true,
                hint_offset = 1,
            })
        end, "hop to till before occurrence of char to the left")
    end,
}
