
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
