
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

""remap our split keys
map <C-Left> :call WinMove('h')<cr>
map <C-Up> :call WinMove('k')<cr>
map <C-Right> :call WinMove('l')<cr>
map <C-Down> :call WinMove('j')<cr>

""terminal
tnoremap <C-Left> <C-\><C-n>:call WinMove('h')<cr>
tnoremap <C-Up> <C-\><C-n>:call WinMove('k')<cr>
tnoremap <C-Right> <C-\><C-n>:call WinMove('l')<cr>
tnoremap <C-Down> <C-\><C-n>:call WinMove('j')<cr>
tnoremap <Esc><Esc> <C-\><C-n>
command! T execute 'terminal' | :call WinMove('j') | :q
