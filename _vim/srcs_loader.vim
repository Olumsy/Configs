let s:_srcs_path = expand('<sfile>:p:h') . '/_srcs'
let g:enable_colorscheme = 0

" Uncomment the features you want to enable:

 execute 'source ' . s:_srcs_path . '/main_settings.vim'	|	" Main settings
 execute 'source ' . s:_srcs_path . '/splitctl.vim'		|	" Split with arrow keys + ctrl
 execute 'source ' . s:_srcs_path . '/typing_assist.vim'	|	" Always recommend words while typing them
 execute 'source ' . s:_srcs_path . '/fast_main.vim'		|	" Make a c main func by writing 'mmm'
" execute 'source ' . s:_srcs_path . '/easy_comment.vim'	|	" Press ctrl+k to comment n lines in c
 execute 'source ' . s:_srcs_path . '/remap_jj.vim'		|	" Write jj to leave insert mode
 execute 'source ' . s:_srcs_path . '/remap_alto.vim'		|	" Press alt+o to append an empty line under the cursor
 let g:enable_colorscheme = 1								|	" Enable custom themes (choose the theme under the 'Themes' header)

" Themes:
if g:enable_colorscheme
	let s:themes_path = s:_srcs_path . '/colors'
	execute 'set runtimepath+=' . s:_srcs_path

	" Replace X by the theme you want:
	" 				calm_forest
	" 				darktheme
	" 				flesh_and_blood
	colorscheme darktheme
endif
