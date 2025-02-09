" Set options and add mapping such that Vim behaves a lot like MS-Windows
"
" set the 'cpoptions' to its Vim default
" plugins
call plug#begin()
Plug 'ludovicchabant/vim-gutentags'
Plug 'preservim/tagbar'
call plug#end()

nmap <F8> :TagbarToggle<CR>

"set number
set relativenumber
set number
let numstyle=2
"set mouse=ni
map <silent><F6> :let numstyle=(numstyle+1)%3<CR>:let &number=(numstyle>=1)<CR>:let &relativenumber=(numstyle==2)<CR>
set ttymouse=xterm2
set cpo=aABceFs
set tabstop=8
set softtabstop=2
set shiftwidth=2
set noautoindent
set expandtab
set cursorline
set cursorcolumn
if &diff
    set nocursorline
    set nocursorcolumn
endif
filetype plugin indent off
set nocindent
set noshowmatch
set noautochdir
set tags=tags;,.findf_tags
set hlsearch
set incsearch
set history=100
set title
set viminfo='1000,"50,h,rA:,rB:
set showcmd
set wildchar=<TAB>
set shortmess=filnxtToO
set ru
syntax on

"233=#121212 220=#ffd700 16=#000000
highlight Comment ctermfg=240
highlight Repeat ctermfg=white cterm=bold
highlight Conditional ctermfg=white cterm=bold
highlight Type ctermfg=white cterm=bold
highlight String ctermfg=darkgreen
highlight Special ctermfg=green
highlight Number ctermfg=blue
highlight Statement ctermfg=white
highlight Constant ctermfg=blue
highlight PreProc ctermfg=darkblue
highlight Search ctermfg=220 ctermbg=none
highlight IncSearch ctermfg=220 ctermbg=none cterm=none
highlight Folded ctermbg=black ctermfg=darkgray
highlight FoldColumn ctermbg=black ctermfg=darkgray
highlight DiffAdd cterm=none ctermbg=233 ctermfg=white
highlight DiffDelete cterm=none ctermbg=black ctermfg=darkgray
highlight DiffText cterm=bold ctermbg=233 ctermfg=204
highlight DiffChange cterm=none ctermbg=233
highlight MatchParen cterm=bold ctermbg=none ctermfg=220
highlight CursorLine ctermfg=NONE ctermbg=16 cterm=none
highlight CursorColumn ctermfg=NONE ctermbg=16 cterm=none
highlight VertSplit ctermbg=black cterm=NONE ctermfg=darkgray
highlight Pmenu ctermbg=darkgray cterm=NONE ctermfg=black
highlight PmenuSel ctermbg=gray cterm=NONE ctermfg=black
highlight TabLineSel cterm=NONE ctermbg=236 ctermfg=gray
highlight TabLine cterm=NONE ctermbg=234 ctermfg=darkgray
highlight TabLineFill cterm=NONE ctermbg=234 ctermfg=darkgray
highlight Todo cterm=reverse ctermfg=221 ctermbg=black
highlight ColorColumn cterm=NONE ctermbg=233 ctermfg=none
highlight NonText ctermfg=darkgray
highlight SpecialKey ctermfg=235
highlight LineNr     ctermfg=darkgray
highlight CursorLineNr ctermfg=gray
highlight Visual ctermbg=white ctermfg=black


set list
set listchars=tab:»»,nbsp:¬,trail:░,precedes:«,extends:»

highlight LeadingTab ctermfg=238
match LeadingTab /^\t\t*/

highlight TrailingSpace ctermfg=240
match TrailingSpace /\s\s*$/

" mark column 80 and 120+
let &colorcolumn="81,".join(range(121,999),",")

" set 'selection', 'selectmode', 'mousemodel' and 'keymodel' for MS-Windows
behave mswin

set backupcopy=yes
set backupdir=~/tmp
" backspace and cursor keys wrap to previous/next line
set backspace=2 whichwrap+=<,>,[,]
set linebreak

" backspace in Visual mode deletes selection
vnoremap <BS> d

" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
vnoremap <S-Del> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

set wrap

"map <F2> :set hlsearch!<C-M>
map <F3> :set wrap!<C-M>
map <F4> :qa<CR>
map <F5> :wqa!<CR>
map <F9> ]czz
map <F11> ]czz
map <F12> :diffg 2<CR>:diffu<CR>
map <F10> :buffers<CR>:buffer
map <Up> gk
map <Down> gj
map <Home> g^
map <End> g$
" CTRL-V and SHIFT-Insert are Paste
map <C-V>               "+gP
map <S-Insert>          "+gP
map! <C-?> <C-H>

cmap <C-V>              <C-R>+
cmap <S-Insert>         <C-R>+

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
if has("virtualedit")
  nnoremap <silent> <SID>Paste :call <SID>Paste()<CR>
  func! <SID>Paste()
    let ove = &ve
    set ve=all
    normal `^"+gPi^[
    let &ve = ove
  endfunc
  inoremap <script> <C-V>       x<BS><Esc><SID>Pastegi
  vnoremap <script> <C-V>       "-c<Esc><SID>Paste
else
  nnoremap <silent> <SID>Paste  "=@+.'xy'<CR>gPFx"_2x
  inoremap <script> <C-V>       x<Esc><SID>Paste"_s
  vnoremap <script> <C-V>       "-c<Esc>gix<Esc><SID>Paste"_x
endif
imap <S-Insert>         <C-V>
vmap <S-Insert>         <C-V>

" Use CTRL-Q to do what CTRL-V used to do
noremap <C-Q>           <C-V>

" Use CTRL-S for saving, also in Insert mode
noremap <C-S>           :update<CR>
vnoremap <C-S>          <C-C>:update<CR>
inoremap <C-S>          <C-O>:update<CR>

" For CTRL-V to work autoselect must be off.
" On Unix we have two selections, autoselect can be used.
if !has("unix")
  set guioptions-=a
endif

" CTRL-Z is Undo; not in cmdline though
noremap <C-Z> u
inoremap <C-Z> <C-O>u

" CTRL-Y is Redo (although not repeat); not in cmdline though
noremap <C-Y> <C-R>
inoremap <C-Y> <C-O><C-R>

" Alt-Space is System menu
if has("gui")
  noremap <M-Space> :simalt ~<CR>
  inoremap <M-Space> <C-O>:simalt ~<CR>
  cnoremap <M-Space> <C-C>:simalt ~<CR>
endif

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G

" CTRL-Tab is Next window
noremap <C-Tab> <C-W>w
inoremap <C-Tab> <C-O><C-W>w
cnoremap <C-Tab> <C-C><C-W>w

" CTRL-F4 is Close window
noremap <C-F4> <C-W>c
inoremap <C-F4> <C-O><C-W>c
cnoremap <C-F4> <C-C><C-W>c

if has ("autocmd")
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g`\"" |
        \ endif
endif

" auto accept extra_conf
let g:ycm_confirm_extra_conf = 0
" don't need diagnostic function from ycm
let g:ycm_show_diagnostics_ui = 0
let g:ycm_key_invoke_completion = '<C-b>'
