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
        completionMatcher: 'icase',
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
        {
            name: '[Java|Type]Script language server',
            filetype: [ 'javascript', 'typescript' ],
            path: 'typescript-language-server',
            args: [ '--stdio' ],
            initializationOptions: {
                preferences: {
                    quotePreference: 'auto',
                    allowTextChangesInNewFiles: true,
                },
            },
        },
        {
            name: 'HTML language server',
            filetype: [ 'html', 'jst', 'razor' ],
            path: 'vscode-html-language-server',
            args: [ '--stdio' ],
        },
        {
            name: 'CSS language server',
            filetype: [ 'css' ],
            path: 'vscode-css-language-server',
            args: [ '--stdio' ],
        },
        {
            name: 'JSON language server',
            filetype: [ 'json' ],
            path: 'vscode-json-language-server',
            args: [ '--stdio' ],
        },
        {
            name: 'Markdown language server',
            filetype: [ 'markdown' ],
            path: 'vscode-markdown-language-server',
            args: [ '--stdio' ],
        },
        {
            name: 'Python language server',
            filetype: [ 'python' ],
            path: 'pyright-langserver',
            args: [ '--stdio' ],
            workspaceConfig: {
                python: {
                    pythonPath: 'python'
                }
            },
        },
        {
            name: 'C# language server',
            filetype: [ 'cs' ],
            path: 'csharp-ls',
            #path: $HOME .. '/.omnisharp/OmniSharp',
            #args: [ '-z', '-lsp', '-e', 'utf-8', '-hpid', getpid(),
            #    'DotNet:EnablePackageRestore=false',
            #    'MsBuild:LoadProjectsOnDemand=true',
            #    'Sdk:IncludePrereleases=true',

            #    'FormattingOptions:EnableEditorConfigSupport=true',
            #    'FormattingOptions:OrganizeImports=true',

            #    'RoslynExtensionsOptions:EnableAnalyzersSupport=true',
            #    'RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true',
            #    'RoslynExtensionsOptions:EnableImportCompletion=true',

            #    'Script:Enabled=true',
            #    'Script:DefaultTargetFramework=net6.0',
            #    'Script:EnableScriptNuGetReferences=true',

            #    'RenameOptions:RenameInComments=true',
            #    'RenameOptions:RenameOverloads=true',
            #]
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

