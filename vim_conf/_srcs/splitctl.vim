
"==============================================
"               cool splitting
"==============================================

" split automatically if window doesn't exist
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) "we haven't moved
    if (match(a:key,'[jk]')+1) "we want to go up/down
      wincmd s
    elseif (match(a:key,'[hl]')+1) "we want to go left/right
      wincmd v
    endif
    exec "wincmd ".a:key
  endif
endfunction

""remap our split keys
map <C-Left> :call WinMove('h')<cr>
map <C-Up> :call WinMove('k')<cr>
map <C-Right> :call WinMove('l')<cr>
map <C-Down> :call WinMove('j')<cr>


" Function to insert comment block
function! InsertCommentBlock()
  " Prompt the user for the number of lines
  let l:number_of_lines = input('Enter number of lines for comment block: ') 

  " Insert /* at the start of the current line
  normal! O/*

  " Move to the line after the current one and insert */
  execute "normal! " . (l:number_of_lines + 2) . "jO*/"

  " Move back to the starting position (the original line)
  normal! k
endfunction

" Map <C-k> to call the InsertCommentBlock function
nnoremap <C-k> :call InsertCommentBlock()<CR>
