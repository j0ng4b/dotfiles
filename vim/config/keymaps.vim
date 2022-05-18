""
"""  Keymaps
""""

"" Change map leaderr
let mapleader = '\'

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

"" Delete buffer
map  bd      <Cmd>bdelete<CR>
map  bw      <Cmd>bwipeout<CR>
map  bu      <Cmd>bunload<CR>

"" Move between buffers
map  bn      <Cmd>bnext<CR>
map  bp      <Cmd>bprevious<CR>

map  bf      <Cmd>bfirst<CR>
map  bl      <Cmd>blast<CR>

