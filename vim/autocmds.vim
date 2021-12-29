""
"""  Autocmds
""""

"" Highlight search only when searching
augroup HighlightSearch
	autocmd!
	autocmd CmdLineEnter /,? set hlsearch
	autocmd CmdLineLeave /,? set nohlsearch
augroup END


"" Fix Tab key when having VimCompletesMe and SnipMate
function! FixVimCompletesMe()
	let l:tab = pumvisible() ? "\<Tab>" : TriggerSnippet()

	if l:tab == "\<Tab>"
		let l:tab = VimCompletesMe#vim_completes_me(0)
	endif

	return l:tab
endfunction

augroup FixVimCompletesMeWithSnipMate
	autocmd!
	autocmd VimEnter * imap <silent> <Tab> <C-R>=FixVimCompletesMe()<CR>
augroup END

