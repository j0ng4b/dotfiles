vim9script

#############################
####    CONFIGURATION    ####
#############################

g:lightline = {
    colorscheme: g:colors_name,

    separator: { 'left': '', 'right': '' },
    subseparator: { 'left': '', 'right': '' },

    mode_map: {
        n: 'Normal',
        i: 'Insert',
        R: 'Replace',
        v: 'Visual',
        V: 'V·Line',
        "\<C-v>": 'V·Block',
        c: 'Command',
        s: 'Select',
        S: 'S·Line',
        "\<C-s>": 'S·Block',
        t: 'Terminal',
    },
}

