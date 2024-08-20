local status, base = pcall(require, 'mini.base16')
if not status then
    return
end

local pallete
if vim.o.background == 'dark' then
    pallete = {
        base00 = '#141b1e',
        base01 = '#1e2528',
        base02 = '#282f32',
        base03 = '#2d3437',
        base04 = '#3c4346',
        base05 = '#dadada',
        base06 = '#e4e4e4',
        base07 = '#dadada',
        base08 = '#e57474',
        base09 = '#fcb163',
        base0A = '#e5c76b',
        base0B = '#8ccf7e',
        base0C = '#6cbfbf',
        base0D = '#67b0e8',
        base0E = '#c47fd5',
        base0F = '#ef7d7d',
    }
end

if pallete then
    base.setup({
        palette = pallete
    })

    vim.g.colors_name = 'everblush'
end

