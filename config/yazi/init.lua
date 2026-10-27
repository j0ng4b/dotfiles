require("session"):setup({
    sync_yanked = true,
})

-- Status bar: owner:group of the hovered file
Status:children_add(function()
    local hovered = cx.active.current.hovered
    if not hovered or ya.target_family() ~= "unix" then
        return ""
    end

    return ui.Line({
        ui.Span(ya.user_name(hovered.cha.uid) or tostring(hovered.cha.uid)):fg("magenta"),
        ":",
        ui.Span(ya.group_name(hovered.cha.gid) or tostring(hovered.cha.gid)):fg("magenta"),
        " ",
    })
end, 500, Status.RIGHT)
