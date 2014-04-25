" Vim plugin for using ftp simply.
" Auther: mori <y326045@yahoo.co.jp>
" License: This file is placed in the public domain.

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim
if exists('g:loaded_small_ftp')
		finish
endif
let g:loaded_small_ftp = 1

let s:save_cpo = &cpo
set cpo&vim

" Offer plugs
noremap <silent> <Plug>(get) :<c-u>call ftp#ftp#Gf()<CR>
noremap <silent> <Plug>(del) :<c-u>call ftp#ftp#Df()<CR>
noremap <silent> <Plug>(rename) :<c-u>call ftp#ftp#RNf()<CR>
noremap <silent> <Plug>(mkdir) :<c-u>call ftp#ftp#MDf()<CR>
noremap <silent> <Plug>(rmdir) :<c-u>call ftp#ftp#RMf()<CR>
noremap <silent> <Plug>(chmod) :<c-u>call ftp#ftp#PMf()<CR>
noremap <silent> <Plug>(sort) :<c-u>call ftp#ftp#STf()<CR>
noremap <silent> <Plug>(reverse) :<c-u>call ftp#ftp#RVf()<CR>

" Default mappings
nmap <unique> <silent> <Enter> <Plug>(get)
nmap <unique> <silent> <del> <Plug>(del)
nmap <unique> <silent> <F2> <Plug>(rename)
nmap <unique> <silent> <F3> <Plug>(mkdir)
nmap <unique> <silent> <F4> <Plug>(rmdir)
nmap <unique> <silent> <F5> <Plug>(chmod)
nmap <unique> <silent> <F6> <Plug>(sort)
nmap <unique> <silent> <F7> <Plug>(reverse)


if !exists(":SmallFtp")
	command! SmallFtp call ftp#ftp#Ftpg()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
