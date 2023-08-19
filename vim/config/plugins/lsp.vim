vim9script

#############################
####    CONFIGURATION    ####
#############################

def SetupLsp(): void
    g:LspOptionsSet({
        autoHighlight: true,

        noNewlineInCompletion: true,
        customCompletionKinds: true,
        completionTextEdit: true,
        completionMatcher: 'fuzzy',
        completionKinds: {
			Text: '󰉿',
			Method: '󰆧',
			Function: '󰊕',
			Constructor: '',
			Field: '󰜢',
			Variable: '',
			Class: '󰠱',
			Interface: '',
			Module: '',
			Property: '󰜢',
			Unit: '󰑭',
			Value: '󰎠',
			Enum: '',
			Keyword: '󰌋',
			Snippet: '',
			Color: '󰏘',
			File: '󰈙',
			Reference: '󰈇',
			Folder: '󰉋',
			EnumMember: '',
			Constant: '󰏿',
			Struct: '󰙅',
			Event: '',
			Operator: '󰆕',
			TypeParameter: '',
			Buffer: '',
        },

        diagSignErrorText: '',
        diagSignHintText: '󰌵',
        diagSignInfoText: '',
        diagSignWarningText: '󰉀',
        diagVirtualTextAlign: 'after',
        showDiagWithVirtualText: true,

        snippetSupport: v:true,
        vsnipSupport: v:true,

        outlineOnRight: true,
        outlineWinSize: 30,

        showInlayHints: true,
        usePopupInCodeAction: true,
    })

    g:LspAddServer([
        {
            name: 'C/C++ language server',
            filetype: [ 'c', 'cpp' ],
            path: 'clangd',
            args: [ '--background-index', '--clang-tidy' ],
        },
    ])
enddef

def SetupLspBuffer(): void
    var maps = {
        'gd': ':LspGotoDefinition',
        'gi': ':LspGotoImpl',
        'gt': ':LspGotoTypeDef',
        'gs': ':LspDocumentSymbol',
        'gS': ':LspSymbolSearch',
        'gr': ':LspPeekReferences',
        'gR': ':LspRename',
        ']g': ':LspDiag next',
        '[g': ':LspDiag prev',
    }

    &l:keywordprg = ':LspHover'
    &l:tagfunc = 'lsp#lsp#TagFunc'
    &l:formatexpr = 'lsp#lsp#FormatExpr()'

    for [key, value] in items(maps)
        execute 'nmap <buffer> <silent> ' .. key .. ' <Cmd>' .. value .. '<CR>'
    endfor
enddef


#############################
####      AUTOCMDS       ####
#############################

augroup Lsp
    autocmd!
    autocmd VimEnter * SetupLsp()
    autocmd User LspAttached SetupLspBuffer()
augroup END


#############################
####      KEYMAPS        ####
#############################

imap <expr> <CR> pumvisible() ? '<C-y>' : '<Plug>delimitMateCR<Plug>DiscretionaryEnd'

