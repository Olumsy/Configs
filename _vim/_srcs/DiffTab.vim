" difftab.vim - compare two visual selections side by side
"
" Usage:
"   :'<,'>DiffTab   1st call: opens a tab "difftab" with the snippet, you stay where you were
"   :'<,'>DiffTab   2nd call: opens the snippet next to the first one, you land in the difftab
"   :'<,'>DiffTab   3rd+ call: replaces the right-hand snippet
"   :DiffTabClose   closes the difftab
"
" In the difftab, n / N jump to the next / previous difference (like ]c / [c)
" and the difference under the cursor is highlighted with CurrentDiff.
"
" Options:
"   let g:difftab_remap = 0    " keep n / N as search keys in the difftab
"
" Without a range, the whole buffer is used.

if exists('g:loaded_difftab')
  finish
endif
let g:loaded_difftab = 1

" ---------------------------------------------------------------------------
" Highlight of the current difference
" ---------------------------------------------------------------------------

function! s:DefineHl() abort
  " 'default' lets you override it in your vimrc / colorscheme
  highlight default CurrentDiff guibg=#8a5200 guifg=NONE ctermbg=94 ctermfg=NONE gui=bold cterm=bold
  " modified words (the DiffText parts) inside the current difference
  highlight default CurrentDiffText guibg=#d01010 guifg=#ffffff ctermbg=160 ctermfg=15 gui=bold cterm=bold
endfunction

function! s:ClearHl() abort
  for l:id in get(w:, 'difftab_ids', [])
    silent! call matchdelete(l:id)
  endfor
  let w:difftab_ids = []
  let w:difftab_range = []
endfunction

" Highlights the hunk under the cursor (the contiguous lines that belong to the diff)
function! s:UpdateHl(force) abort
  if !exists('t:difftab') || !&diff
    call s:ClearHl()
    return
  endif

  let l:lnum = line('.')
  if diff_hlID(l:lnum, 1) == 0
    call s:ClearHl()
    return
  endif

  let l:s = l:lnum
  while l:s > 1 && diff_hlID(l:s - 1, 1) != 0
    let l:s -= 1
  endwhile
  let l:e = l:lnum
  let l:last = line('$')
  while l:e < l:last && diff_hlID(l:e + 1, 1) != 0
    let l:e += 1
  endwhile

  if !a:force && get(w:, 'difftab_range', []) == [l:s, l:e]
    return
  endif

  call s:ClearHl()
  let l:ids = []
  let l:i = l:s
  " matchaddpos() accepts at most 8 positions per call
  while l:i <= l:e
    call add(l:ids, matchaddpos('CurrentDiff', range(l:i, min([l:i + 7, l:e])), 20))
    let l:i += 8
  endwhile

  " Modified words: columns that Vim marks as DiffText, drawn in red on top
  let l:textid = hlID('DiffText')
  let l:words = []
  for l:l in range(l:s, l:e)
    let l:n = strlen(getline(l:l))
    let l:c = 1
    while l:c <= l:n
      if diff_hlID(l:l, l:c) == l:textid
        let l:start = l:c
        while l:c <= l:n && diff_hlID(l:l, l:c) == l:textid
          let l:c += 1
        endwhile
        call add(l:words, [l:l, l:start, l:c - l:start])
      else
        let l:c += 1
      endif
    endwhile
  endfor
  let l:j = 0
  while l:j < len(l:words)
    call add(l:ids, matchaddpos('CurrentDiffText', l:words[l:j : l:j + 7], 30))
    let l:j += 8
  endwhile

  let w:difftab_ids = l:ids
  let w:difftab_range = [l:s, l:e]
endfunction

augroup difftab
  autocmd!
  autocmd ColorScheme * call s:DefineHl()
  autocmd CursorMoved,WinEnter,TabEnter * call s:UpdateHl(0)
  autocmd TextChanged * call s:UpdateHl(1)
  autocmd WinLeave * call s:ClearHl()
augroup END

call s:DefineHl()

" ---------------------------------------------------------------------------
" Tab / buffer handling
" ---------------------------------------------------------------------------

" Returns the tab number of the difftab, or 0 if there is none
function! s:FindTab() abort
  for l:t in range(1, tabpagenr('$'))
    if gettabvar(l:t, 'difftab', 0)
      return l:t
    endif
  endfor
  return 0
endfunction

function! s:Scratch(name, ft) abort
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  if a:ft !=# ''
    let &l:filetype = a:ft
  endif
  silent! execute 'file ' . fnameescape(a:name)
  if get(g:, 'difftab_remap', 1)
    nnoremap <buffer> <silent> n ]c
    nnoremap <buffer> <silent> N [c
  endif
endfunction

function! s:Replace(lines) abort
  setlocal modifiable
  silent %delete _
  call setline(1, a:lines)
endfunction

function! s:DiffTab(line1, line2) abort
  let l:lines   = getline(a:line1, a:line2)
  let l:ft      = &filetype
  let l:origwin = win_getid()
  let l:t       = s:FindTab()

  if l:t == 0
    " First call: create the tab, then go back to where we were
    tabnew
    let t:difftab = 1
    call setline(1, l:lines)
    call s:Scratch('difftab', l:ft)
    call win_gotoid(l:origwin)
    return
  endif

  " Next calls: jump to the difftab
  execute 'tabnext' l:t

  if winnr('$') == 1
    " Second snippet, opened to the right of the first one
    rightbelow vnew
    call setline(1, l:lines)
    call s:Scratch('difftab-2', l:ft)
  else
    " Already two snippets: replace the right-hand one
    2wincmd w
    call s:Replace(l:lines)
    if l:ft !=# ''
      let &l:filetype = l:ft
    endif
  endif

  " Diff the two windows (and nothing else)
  diffoff!
  1wincmd w
  diffthis
  2wincmd w
  diffthis
  diffupdate
  normal! gg
  call s:UpdateHl(1)
endfunction

function! s:DiffTabClose() abort
  let l:t = s:FindTab()
  if l:t == 0
    echo 'No difftab open'
    return
  endif
  execute 'tabnext' l:t
  tabclose
endfunction

command! -range=% DiffTab call s:DiffTab(<line1>, <line2>)
command! DiffTabClose call s:DiffTabClose()
