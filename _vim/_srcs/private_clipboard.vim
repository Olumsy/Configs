augroup PrivateClip
	autocmd!
		autocmd TextYankPost * if v:event.operator ==# 'y'
			\ | call setreg('z', v:event.regcontents, v:event.regtype)
			\ | endif
augroup END

nnoremap <C-\>p "zp
nnoremap <C-\>P "zP
xnoremap <C-\>p "zp
inoremap <C-\>p <C-r>z
