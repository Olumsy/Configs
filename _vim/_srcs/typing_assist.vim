"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart case-sensitive search
set ignorecase				 " Ignore case in search patterns
set smartcase					" Override ignorecase if search pattern contains uppercase
" Configure completion menu
set completeopt=menuone,noinsert,noselect,longest		" Show menu even for single match, don't auto-insert
set shortmess+=c			 " Don't show completion messages
set pumheight=10			 " Limit completion menu height
set pumwidth=10				" Limit completion menu width

" Set up in-memory dictionary
autocmd BufEnter * let s:_srcs_path = expand('<sfile>:p:h')
autocmd BufEnter * let s:extension = substitute(expand('%:t'), '..*\.', '', '') 
autocmd BufEnter * let s:dict_path = s:_srcs_path . '/dict/' . s:extension . '.dict'
autocmd BufEnter * call SetupRamDict()

let s:completion_bool = 1
let s:matches = []

" Load dictionary into RAM and set up custom completion
function! SetupRamDict()
	set completefunc=RamDictComplete
	if filereadable(expand(s:dict_path))
		" Read dictionary into a list variable
		let s:ram_dict = readfile(s:dict_path)
		
		" Set up completion function
		
		" Make sure dictionary is empty so it doesn't show paths
		set dictionary=
	else
		" Reset if no dictionary exists
		let s:ram_dict = []
	endif
endfunction

" Custom completion function using RAM dictionary
function! RamDictComplete(findstart, base)
	if a:findstart
		" Locate the start of the word
		let line = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\w'
			let start -= 1
		endwhile
		return start
	else
		let s:matches = []
		for word in s:ram_dict
			if word =~ '^' . a:base
				call add(s:matches, word)
			endif
		endfor
		let s:matches += FileWordComplete(a:base, 'self')
		" echom s:matches
		return {'words': s:matches, 'refresh': 'always'}
	endif
endfunction

function! FileWordComplete(base, filename)
	" Get the current file name in the form of './filename'
	" echom "x"

	" Read lines from the specified file
	let path = expand('%:p:h') . '/'
	if a:filename == 'self'
		let lines = getline(1, '$')
	else
		let lines = readfile(a:filename)
	endif

	" Extract words from all lines using regex
	let words = {}
	for line in lines
		if line =~ '\v#\s*include\s*"\zs.*\ze"'
			let new_file = matchstr(line, '\v#\s*include\s*"\zs.*\ze"')
			let g:include_paths = systemlist('make -Bn 2>/dev/null | grep -o "\-I[^ ]*" | sed "s/^-I//" | sort -u')
			call add(g:include_paths, '')
			for path in g:include_paths
				let include_file = path . "/" . new_file
				let final_path = expand(getcwd() . "/" . include_file)
				" echom path include_file "," final_path
				if filereadable(final_path) | for word in FileWordComplete(a:base, final_path) | let words[word] = 1 | endfor | endif
			endfor
		endif
		let temp_words = split(line, '\W\+')
		for word in temp_words
			if word =~ '^' . a:base | let words[word] = 1 | endif
		endfor
	endfor

	" Remove duplicates
	" let words = uniq(sort(words))

	" Filter words that start with the given base
	"let matches = filter(words, 'v:val =~ "^" . a:base')
	let matches = keys(words)
	return matches
endfunction

" function! FileWordComplete(base)
"	 " Get all lines from the current file
"	 let lines = getline(1, '$')
" 
"	 " Extract words from all lines using regex
"	 let words = []
"	 for line in lines
"		 let words += split(line, '\W\+')
"	 for line in lines
"		 let words += split(line, '\s')
"	 endfor
" 
"	 " Remove duplicates
"	 let words = uniq(sort(words))
" 
"	 " Filter words that start with the given base
"	 let matches = filter(words, 'v:val =~ "^" . a:base')
" 
"	 return matches
" endfunction

let g:is_completing = 0
function! CompleteCaller()
	if g:is_completing | return | endif
	let g:is_completing = 1
	" echom "hey"
	if v:char =~ '\w'
		call feedkeys("\<C-x>\<C-u>", 'n')
	endif
	let g:is_completing = 0
	return
endfunction
" Change the auto-trigger to use our custom completion function
autocmd InsertCharPre * if !g:is_completing | call CompleteCaller()

" Keep the remaining settings
set complete+=i				" Remove included files from completion sources
set complete-=t				" Remove tag files from completion sources
set complete+=k
set complete+=w
set complete-=b
filetype plugin on
set omnifunc=syntaxcomplete#Complete
