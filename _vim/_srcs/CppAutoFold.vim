" ---- Auto-fold C/C++ functions when the cursor leaves them ----

function! s:IsFunctionBrace(lnum, col) abort
  " Text before the '{'; if the brace is alone on its line (Allman style),
  " look at the previous non-blank line instead.
  let text = strpart(getline(a:lnum), 0, a:col - 1)
  if text =~ '^\s*$'
    let prev = prevnonblank(a:lnum - 1)
    if prev == 0 | return 0 | endif
    let text = getline(prev)
  endif
  let text = substitute(text, '//.*$', '', '')
  if text =~ '^\s*\%(if\|for\|while\|switch\|catch\|else\|do\)\>'
    return 0
  endif
  return text =~ ')\s*\%(\<\%(const\|noexcept\|override\|final\|volatile\)\>\|noexcept([^)]*)\|&&\?\|->[^{;]*\|\s\)*$'
endfunction

" Returns [start, end] of the outermost function containing the cursor, or [].
function! s:FuncRange() abort
  let save = getpos('.')
  let skip = "synIDattr(synID(line('.'),col('.'),0),'name') =~? 'comment\\|string\\|character'"
  let flags = getline('.')[col('.') - 1] ==# '{' ? 'bcnW' : 'bnW'
  let found = []
  while 1
    let p = searchpairpos('{', '', '}', flags, skip)
    if p[0] == 0 | break | endif
    call cursor(p[0], p[1])
    if s:IsFunctionBrace(p[0], p[1])
      let found = [p[0], p[1]]   " keep going outward: want the outermost
    endif
    let flags = 'bnW'
  endwhile
  let result = []
  if !empty(found)
    call cursor(found[0], found[1])
    let e = searchpairpos('{', '', '}', 'nW', skip)
    if e[0] > 0 | let result = [found[0], e[0]] | endif
  endif
  call setpos('.', save)
  return result
endfunction

function! s:Track() abort
  let l = line('.')
  " Fast path: still inside the same function and nothing changed
  if exists('b:af_range') && !empty(b:af_range) && b:af_tick == b:changedtick
        \ && l >= b:af_range[0] && l <= b:af_range[1]
    return
  endif
  let cur = s:FuncRange()
  if exists('b:af_range') && !empty(b:af_range)
        \ && (empty(cur) || cur[0] != b:af_range[0])
    let s = b:af_range[0]
    if s <= line('$') && foldlevel(s) > 0 && foldclosed(s) == -1
      silent! execute s . 'foldclose'
    endif
  endif
  let b:af_range = cur
  let b:af_tick = b:changedtick
endfunction

function! s:Setup() abort
  setlocal foldmethod=syntax
  setlocal foldlevel=99          " everything open until you leave a function
  setlocal foldcolumn=1
  let b:af_range = []
  let b:af_tick = 0
  augroup CppAutoFold
    autocmd! * <buffer>
    autocmd CursorMoved,CursorMovedI <buffer> call s:Track()
  augroup END
  " Enter opens a closed fold, otherwise behaves normally
  nnoremap <buffer> <expr> <CR> foldclosed('.') != -1 ? 'zo' : "\<CR>"
endfunction

autocmd FileType c,cpp call s:Setup()
