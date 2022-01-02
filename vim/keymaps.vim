""
"""  Keymaps :)
""""

"" Near esc key
imap jk      <Esc>
vmap jk      <Esc>


"" Disable arrow keys
map  <Left>  <Nop>
map  <Right> <Nop>
map  <Up>    <Nop>
map  <Down>  <Nop>

imap <Left>  <Nop>
imap <Right> <Nop>
imap <Up>    <Nop>
imap <Down>  <Nop>


"" Save file
map  <C-S>   <Cmd>w<CR>
map! <C-S>   <Cmd>w<CR>


"" Quit without save
map  <C-Q>   <Cmd>q<CR>
map! <C-Q>   <Cmd>q<CR>


"" Show buffers
map  bs      <Cmd>buffers<CR>

"" Delete buffer
map  bd      <Cmd>bdelete<CR>
map  bw      <Cmd>bwipeout<CR>
map  bu      <Cmd>bunload<CR>

"" Move between buffers
map  bn      <Cmd>bnext<CR>
map  bp      <Cmd>bprevious<CR>

map  bf      <Cmd>bfirst<CR>
map  bl      <Cmd>blast<CR>


"" Window open and close
map  wn      <Cmd>wincmd n<CR>
map  w^      <Cmd>wincmd ^<CR>

map  wc      <Cmd>wincmd c<CR>
map  wo      <Cmd>wincmd o<CR>

"" Move between windows
map  wj      <Cmd>wincmd j<CR>
map  wk      <Cmd>wincmd k<CR>
map  wh      <Cmd>wincmd h<CR>
map  wl      <Cmd>wincmd l<CR>

map  wP      <Cmd>wincmd P<CR>


"" Move windows around
map  wJ      <Cmd>wincmd J<CR>
map  wK      <Cmd>wincmd K<CR>
map  wH      <Cmd>wincmd H<CR>
map  wL      <Cmd>wincmd L<CR>

map  wT      <Cmd>wincmd T<CR>

"" Window resize
map  w=      <Cmd>wincmd =<CR>

map  w-      <Cmd>wincmd -<CR>
map  w+      <Cmd>wincmd +<CR>

map  w<      <Cmd>wincmd <<CR>
map  w>      <Cmd>wincmd ><CR>


"" Change map leaderr
let mapleader = ','

