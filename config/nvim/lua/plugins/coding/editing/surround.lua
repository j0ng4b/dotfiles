return {
    "kylechui/nvim-surround",
    config = function()
        require("nvim-surround").setup({
            move_cursor = "stick",
        })
    end,
}
