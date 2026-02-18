local config = function ()
    require('hop').setup({
        keys = 'etovxqpdygfblzhckisuran',
        uppercase_labels = false,
    })
end

return {
    'smoka7/hop.nvim',
    version = "*",
    config = config,
    keys = {
        { 's', '<cmd>HopChar2AC<cr>', desc = 'Hop to bigram after cursor', mode =  { 'v', 'n' } },
        { 'S', '<cmd>HopChar2BC<cr>', desc = 'Hop to bigram before cursor', mode =  { 'v', 'n' } },
        { ';b', '<cmd>HopWordBC<cr>', desc = 'Hop to word before cursor', mode = { 'v', 'n' } },
        { ';w', '<cmd>HopWord<cr>', desc = 'Hop to word in current buffer', mode = { 'v', 'n' } },
        { ';a', '<cmd>HopWordAC<cr>', desc = 'Hop to word after cursor', mode = { 'v', 'n' } },
        { ';c', '<cmd>HopCamelCaseMW<cr>', desc = 'Hop to camelCase word', mode = { 'v', 'n' } },
        { ';d', '<cmd>HopLine<cr>', desc = 'Hop to line', mode = { 'v', 'n' } },
        { ';f', '<cmd>HopNodes<cr>', desc = 'Hop to node', mode = { 'v', 'n' } },
        { ';s', '<cmd>HopPatternMW<cr>', desc = 'Hop to pattern', mode = { 'v', 'n' } },
        { ';j', '<cmd>HopVertical<cr>', desc = 'Hop to location vertically', mode = { 'v', 'n' } },
    },
}
