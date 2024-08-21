return {
    'sainnhe/gruvbox-material',
    name = 'gruvbox',
    init = function()
        vim.g.gruvbox_material_background = 'hard'
        vim.g.gruvbox_material_foreground = 'original'
        vim.g.gruvbox_material_statusline_style = 'original'

        vim.g.gruvbox_material_show_eob = 0
        vim.g.gruvbox_material_enable_bold = 1
        vim.g.gruvbox_material_enable_italic = 1
        vim.g.gruvbox_material_dim_inactive_windows = 1

        vim.g.gruvbox_material_menu_selection_background = 'yellow'
        vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
        vim.g.gruvbox_material_inlay_hints_background = 'dimmed'
        vim.g.gruvbox_material_spell_foreground = 'colored'
        vim.g.gruvbox_material_ui_contrast = 'high'

        vim.g.gruvbox_material_better_performance = 1
    end
}

