
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
