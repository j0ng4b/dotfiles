vim9script

#############################
####    CONFIGURATION    ####
#############################
def SetupLsp(): void
    if !exists('*g:LspOptionsSet')
        return
    endif

    g:LspOptionsSet({
        aleSupport: true,
        autoHighlight: true,

        noNewlineInCompletion: true,
        completionTextEdit: false,
        completionMatcher: 'fuzzy',

        customCompletionKinds: true,
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

        snippetSupport: v:true,
        vsnipSupport: v:true,

        outlineOnRight: true,
        outlineWinSize: 30,

        semanticHighlight: true,

        showInlayHints: true,
        usePopupInCodeAction: true,

        filterCompletionDuplicates: true,
    })

    var langServers: list<dict<any>> = []
    if executable('clangd')
        langServers += [ {
            name: 'C/C++ language server',
            filetype: [ 'c', 'cpp' ],
            path: 'clangd',
            args: [ '--background-index', '--clang-tidy' ],
        }]
    endif

    if executable('typescript-language-server')
        langServers += [ {
            name: '[Java|Type]Script language server',
            filetype: [ 'javascript', 'typescript' ],
            path: 'typescript-language-server',
            args: [ '--stdio' ],
            initializationOptions: {
                preferences: {
                    quotePreference: 'single',
                    allowTextChangesInNewFiles: true,
                    includeInlayParameterNameHints: 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName: true,
                    includeInlayFunctionParameterTypeHints: true,
                    includeInlayVariableTypeHints: true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName: true,
                    includeInlayPropertyDeclarationTypeHints: true,
                    includeInlayFunctionLikeReturnTypeHints: true,
                    includeInlayEnumMemberValueHints: true,
                },
            },
        }]
    endif

    if executable('vscode-html-language-server')
        langServers += [ {
            name: 'HTML language server',
            filetype: [ 'html', 'jst', 'razor' ],
            path: 'vscode-html-language-server',
            args: [ '--stdio' ],
        }]
    endif

    if executable('vscode-css-language-server')
        langServers += [ {
            name: 'CSS language server',
            filetype: [ 'css' ],
            path: 'vscode-css-language-server',
            args: [ '--stdio' ],
        }]
    endif

    if executable('vscode-json-language-server')
        langServers += [ {
            name: 'JSON language server',
            filetype: [ 'json' ],
            path: 'vscode-json-language-server',
            args: [ '--stdio' ],
        }]
    endif

    if executable('vscode-markdown-language-server')
        langServers += [ {
            name: 'Markdown language server',
            filetype: [ 'markdown' ],
            path: 'vscode-markdown-language-server',
            args: [ '--stdio' ],
        }]
    endif

    if executable('pyright-langserver')
        langServers += [ {
            name: 'Python language server',
            filetype: [ 'python' ],
            path: 'pyright-langserver',
            args: [ '--stdio' ],
            workspaceConfig: {
                python: {
                    pythonPath: 'python'
                }
            },
        }]
    endif

    if executable('pylsp')
        langServers += [ {
            name: 'Python language server',
            filetype: [ 'python' ],
            path: 'pylsp',
            args: [],
        }]
    endif

    if executable('csharp-ls')
        langServers += [ {
            name: 'C# language server',
            filetype: [ 'cs' ],
            path: 'csharp-ls',
        }]
    endif

    if executable($HOME .. '/.omnisharp/OmniSharp')
        langServers += [ {
            name: 'C# language server',
            path: $HOME .. '/.omnisharp/OmniSharp',
            args: [ '-z', '-lsp', '-e', 'utf-8', '-hpid', getpid(),
                'DotNet:EnablePackageRestore=false',
                'MsBuild:LoadProjectsOnDemand=true',
                'Sdk:IncludePrereleases=true',

                'FormattingOptions:EnableEditorConfigSupport=true',
                'FormattingOptions:OrganizeImports=true',

                'RoslynExtensionsOptions:EnableAnalyzersSupport=true',
                'RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true',
                'RoslynExtensionsOptions:EnableImportCompletion=true',

                'Script:Enabled=true',
                'Script:DefaultTargetFramework=net6.0',
                'Script:EnableScriptNuGetReferences=true',

                'RenameOptions:RenameInComments=true',
                'RenameOptions:RenameOverloads=true',
            ]
        }]
    endif

    g:LspAddServer(langServers)
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

    # Fix delimitMate with LSP
    var pairs = split(get(g:, 'delimitMate_matchpairs', []), ',')
    for pair in pairs
        var char = pair[0]
        var map = maparg(char, 'i', false, true)

        # Check for existing LspShowSignature maps that conflict with
        # delimitMate maps
        if stridx(map.rhs, '<C-R>=g:LspShowSignature()<CR>') > -1
            execute $'inoremap <silent> <buffer> {char} {char}'
                .. $'<Plug>delimitMate{char}<C-R>=g:LspShowSignature()<CR><BS>'
        endif
    endfor

    # Show hover information about a symbol when hold cursor
    var ext = expand('%:e')
    execute $'autocmd CursorHold *.{ext} silent LspHover'
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

