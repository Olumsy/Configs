
"==============================================
"               cool splitting
"==============================================

function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) 
    if (match(a:key,'[jk]')+1) 
      wincmd s
    elseif (match(a:key,'[hl]')+1) 
      wincmd v
    endif
    exec "wincmd ".a:key
	exec ":o."
  endif
endfunction

""ctrl + arrows
map <C-Left> :call WinMove('h')<cr>
map <C-Up> :call WinMove('k')<cr>
map <C-Right> :call WinMove('l')<cr>
map <C-Down> :call WinMove('j')<cr>

""ctrl + vim motion
map <C-h> :call WinMove('h')<cr>
map <C-k> :call WinMove('k')<cr>
map <C-l> :call WinMove('l')<cr>
map <C-j> :call WinMove('j')<cr>

""terminal
""ctrl + arrows
tnoremap <C-Left> <C-w>:call WinMove('h')<cr>
tnoremap <C-Up> <C-w>:call WinMove('k')<cr>
tnoremap <C-Right> <C-w>:call WinMove('l')<cr>
tnoremap <C-Down> <C-w>:call WinMove('j')<cr>
""ctrl + vim motion
tnoremap <C-h> <C-w>:call WinMove('h')<cr>
tnoremap <C-k> <C-w>:call WinMove('k')<cr>
tnoremap <C-l> <C-w>:call WinMove('l')<cr>
tnoremap <C-j> <C-w>:call WinMove('j')<cr>

tnoremap <Esc><Esc> <C-\><C-n>
command! T execute 'terminal' | :call WinMove('j') | :q
