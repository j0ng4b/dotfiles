vim9script

import './utils/buffer.vim'

imap jk <Esc>
vmap jk <Esc>

imap <Up>    <Nop>
imap <Left>  <Nop>
imap <Right> <Nop>
imap <Down>  <Nop>

map  <Up>    <Nop>
map  <Left>  <Nop>
map  <Right> <Nop>
map  <Down>  <Nop>

# Make Tab key scroll through the wildmenu
cmap <expr> <Tab> pumvisible() ? '<Down>' : '<Tab>'

imap <C-s>     <Cmd>w<CR>
imap <C-S-s>   <Cmd>wall<CR>

map  <C-s>     <Cmd>w<CR>
map  <C-S-s>   <Cmd>wall<CR>

imap <C-q>     <Cmd>qall<CR>
imap <C-S-q>   <Cmd>qall!<CR>

map  <C-q>     <Cmd>qall<CR>
map  <C-S-q>   <Cmd>qall!<CR>


# Buffer
nmap bo        <Cmd>enew<CR>
nmap bd        <Cmd>call <SID>buffer.BufferClose()<CR>

nmap bn        <Cmd>call <SID>buffer.BufferMove('bnext')<CR>
nmap bp        <Cmd>call <SID>buffer.BufferMove('bprevious')<CR>


# Window
nmap ws        <Cmd>wincmd s<CR>
nmap wv        <Cmd>wincmd v<CR>

nmap wc        <Cmd>wincmd c<CR>

nmap wh        <Cmd>wincmd h<CR>
nmap wj        <Cmd>wincmd j<CR>
nmap wk        <Cmd>wincmd k<CR>
nmap wl        <Cmd>wincmd l<CR>
nmap wp        <Cmd>wincmd p<CR>

nmap wmh       <Cmd>wincmd H<CR>
nmap wmj       <Cmd>wincmd J<CR>
nmap wmk       <Cmd>wincmd K<CR>
nmap wml       <Cmd>wincmd L<CR>


# Tab
nmap to        <Cmd>tabnew<CR>
nmap td        <Cmd>tabclose<CR>

nmap tn        <Cmd>tabnext<CR>
nmap tp        <Cmd>tabprevious<CR>
nmap tf        <Cmd>tabfirst<CR>
nmap tl        <Cmd>tablast<CR>

nmap th       <Cmd>tabmove -<CR>
nmap tr       <Cmd>tabmove +<CR>

nnoremap tt   t

