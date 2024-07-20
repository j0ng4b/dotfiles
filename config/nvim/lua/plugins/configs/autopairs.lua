local status, npairs = pcall(require, 'nvim-autopairs')
if not status then
    return
end

local cond = require('nvim-autopairs.conds')
local Rule = require('nvim-autopairs.rule')

npairs.setup({
    check_ts = true,
})

-- End wise for lua
-- npairs.add_rule(require('nvim-autopairs.rules.endwise-lua'))

-- Expand space rule
local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
npairs.add_rule(
    Rule(' ', ' ')
        :with_pair(function(opts)
            return vim.tbl_contains({
                brackets[1][1] .. brackets[1][2],
                brackets[2][1] .. brackets[2][2],
                brackets[3][1] .. brackets[3][2],
            }, opts.line:sub(opts.col - 1, opts.col))
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        :with_del(function(opts)
            return vim.tbl_contains({
                brackets[1][1] .. '  ' .. brackets[1][2],
                brackets[2][1] .. '  ' .. brackets[2][2],
                brackets[3][1] .. '  ' .. brackets[3][2],
            }, opts.line:sub(opts.col - 2, opts.col + 2))
        end)
)

for _, bracket in ipairs(brackets) do
    npairs.add_rule(
        Rule(bracket[1] .. ' ', ' ' .. bracket[2])
            :with_pair(cond.none())
            :with_move(function(opts)
                return opts.char == bracket[2]
            end)
            :with_del(cond.none())
            :use_key(bracket[2])
    )
end

-- JavaScript family arrow functions
npairs.add_rule(
    Rule('%(.*%)%s*%=>$', ' {  }', { 'typescript', 'typescriptreact', 'javascript' })
        :use_regex(true)
        :set_end_pair_length(2)
)
