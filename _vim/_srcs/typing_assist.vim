"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart case-sensitive search
set ignorecase         " Ignore case in search patterns
set smartcase          " Override ignorecase if search pattern contains uppercase
" Configure completion menu
set completeopt=menuone,noinsert,noselect,longest    " Show menu even for single match, don't auto-insert
set shortmess+=c       " Don't show completion messages
set pumheight=10       " Limit completion menu height
set pumwidth=10        " Limit completion menu width

" Set up in-memory dictionary
autocmd BufEnter * let s:_srcs_path = expand('<sfile>:p:h')
autocmd BufEnter * let s:extension = substitute(expand('%:t'), '..*\.', '', '') 
autocmd BufEnter * let s:dict_path = s:_srcs_path . '/dict/' . s:extension . '.dict'
autocmd BufEnter * call SetupRamDict()
autocmd BufEnter * if filereadable(expand(s:dict_path)) | let s:dict_bool = 1 | else | let s:dict_bool = 0 | endif

" Load dictionary into RAM and set up custom completion
function! SetupRamDict()
  if filereadable(expand(s:dict_path))
    " Read dictionary into a list variable
    let s:ram_dict = readfile(s:dict_path)
    
    " Set up completion function
    set completefunc=RamDictComplete
    
    " Make sure dictionary is empty so it doesn't show paths
    set dictionary=
  else
    " Reset if no dictionary exists
    let s:ram_dict = []
    set completefunc&
  endif
endfunction

" Custom completion function using RAM dictionary
function! RamDictComplete(findstart, base)
  if a:findstart
    " Locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] !~ '\s'
      let start -= 1
    endwhile
    return start
  else
    " Find matching words
    let matches = []
    for word in s:ram_dict
		if word =~ '^' . a:base
			call add(matches, {'word': word, 'menu': ''}) 
		endif
    endfor
	let matches += FileWordComplete(a:base)
    return {'words': matches, 'refresh': 'always'}
  endif
endfunction

function! FileWordComplete(base)
  " Get all lines from the current file
  let lines = getline(1, '$')

  " Extract words from all lines using regex
  let words = []
  for line in lines
    let words += split(line, '\W\+')
  endfor

  " Remove duplicates
  let words = uniq(sort(words))

  " Filter words that start with the given base
  let matches = filter(words, 'v:val =~ "^" . a:base')

  return matches
endfunction

function! CompleteCall()
	if s:dict_bool
		call feedkeys("\<C-x>\<C-u>", 'n')
		return
	endif
		if !pumvisible()
			call feedkeys("\<C-p>", 'n')
		endif
endfunction
" Change the auto-trigger to use our custom completion function
" inoremap <expr> <C-p> pumvisible() ? "\<C-p>" : "\<C-p>"
autocmd InsertCharPre * if v:char =~ '\w' | call CompleteCall() | endif

" Keep the remaining settings
set dictionary+=./
set complete+=i        " Remove included files from completion sources
set complete-=t        " Remove tag files from completion sources
set complete+=k
set complete+=w
set complete-=b
filetype plugin on
set omnifunc=syntaxcomplete#Complete
