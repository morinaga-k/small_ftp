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

command! SmallFtp call ftp#ftp#Ftpg()

let &cpo = s:save_cpo
unlet s:save_cpo
