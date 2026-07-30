" :<range>CppClass to create the class with name within <range>

function! s:InsertCppClass() range
	let l:lines = getline(a:firstline, a:lastline)
	let l:name  = trim(join(l:lines, ' '))

	let l:snip = [
		\ 'class ' . l:name,
		\ '{',
		\ '	private:',
		\ '',
		\ '	public:',
		\ '		' . l:name . '();',
		\ '		' . l:name . '(const ' . l:name . '& other) = delete;',
		\ '		' . l:name . '& operator=(const ' . l:name . '& other) = delete;',
		\ '		~' . l:name . '();',
		\ '};',
		\ ]

	execute a:firstline . ',' . a:lastline . 'd_'
	call append(a:firstline - 1, l:snip)

	call cursor(a:firstline, 1)
endfunction

command! -range CppClass <line1>,<line2>call s:InsertCppClass()
