scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:fin=1
let s:cwd="/cgi/\r"
let s:fl = []
let s:prevwd = []
function! ftp#ftp#Ftpleave()
		if s:fin == 1
				let s:fl[3] = "cd " . s:cwd
				call writefile(s:fl, "_ftprc", "b")
		else
		endif
		r !del /q /f "c:\Program Files\Vim\vimfiles\autoload\ftp\tmp\%:t"
		r !del /q /f $Vim\vimfiles\autoload\ftp\ftp
endfunction

function! s:Cutspce()
		1delete
		3delete
		4delete
endfunction

function! s:Threewinc(bl)
	3winc w
	1,$delete
	r !ftp -s:_ftprc
	call s:Cutspce()
	%call s:Snip('1111111')
	call cursor(expand("G"), 1)
	if a:bl != 0
		call s:Getlist()
	endif
endfunction

function! s:MDf()
	let newdir = input("mkdir ")
	if newdir = ""
		return
	endif
	let s:fl[5] = "mkdir " . newdir . "\r"
	call writefile(s:fl, "_ftprc", "b")
	call s:Threewinc(1)
endfunction

function! s:RNf()
	let oldname = expand("<cfile>")
	let newname = input("rename to ")
	if newname == ""
			return
	endif
	if newname !~ "[.]"
		let newname = newname . "." . expand("<cfile>:e")
	endif
	let s:fl[5] = "rename " . oldname . " " . newname . "\r"
	call writefile(s:fl, "_ftprc", "b")
	call s:Threewinc(1)
endfunction

function! s:Df()
	let dest = expand("<cfile>")
	let s:fl[5] = "del " . dest . "\r"
	call writefile(s:fl, "_ftprc", "b")
	" Change to function berow.
	call s:Threewinc(1)
endfunction

fun! Echo(txt)
	echo a:txt
	3sleep
endfun

function! s:Gf()
		if getcwd() != "$vim/vimfiles/autoload/ftp"
				cd $vim/vimfiles/autoload/ftp
		endif
		let dest = expand("<cfile>")
		let res = match(dest, "../")
		if res != -1
				if s:fl[3] == "cd /"
						return
				endif
				if s:fl[3] =~ "^\r"
					echo "find cr at head of line"
					3sleep
				endif
				let s:fl[3] = remove(s:prevwd, len(s:prevwd)-1)
				echo "Parent directory is " . s:fl[3]
				call writefile(s:fl, "_ftprc", "b")
				2winc w
				silent 1,$delete
				silent call s:Getlist()
				return 
		endif

		let res = match(dest, "[.]")
		if res == -1
				call add(s:prevwd, s:fl[3])
				let s:fl[3] = s:fl[3][0: strlen(s:fl[3]) - 2]
				let s:fl[3] = s:fl[3] . dest . "\/\r"
				call writefile(s:fl, "_ftprc", "b")
				silent call s:Getlist()
				return
		endif

		cd $vim/vimfiles/autoload/ftp/tmp/
		3winc w
		r !del *.txt *.cgi *.html
		cd $vim/vimfiles/autoload/ftp
		let s:fl = readfile("_ftprc", "b")
		if len(s:fl) >= 7
				call remove(s:fl, 5, len(s:fl)-1)
				" no need berow.
				call writefile(s:fl, "_ftprc", "b")
		endif
		call add(s:fl, "get " . dest . "\r")
		call add(s:fl, "disconnect\r")
		call add(s:fl, "bye")
		call writefile(s:fl, "_ftprc", "b")
		call s:Threewinc(0)
		cd $vim/vimfiles/autoload/ftp/tmp/
		1winc w
		w! tmp 
		exe "e " . dest
		1winc w
endfunction

function! s:Snip(t)
		let str = getline('.')	
		let pass = match(str, 'Password')
		if pass != -1
				let strt = stridx(str, "d")
				let strt = strpart(str, 0, strt + 1)
				let strt = strt . " *********"
				call setline('.', strt)
		endif
		let res = match(str, a:t)
		if res != -1
				delete
		endif
endfunction

function! s:Getlist()
		2winc w
		silent 1,$delete
		let s:fl[5] = "ls\r"
		silent call writefile(s:fl, "_ftprc", "b")
		cd $vim/vimfiles/autoload/ftp
		silent r !ftp -s:_ftprc
		%s///g
		%call s:Snip('^\.')
		call cursor(expand("$"),1)
		for i in range(1,3)
				delete
		endfor
		silent 1,13delete
		%call s:Snip('^\.')
		call setline(expand("$"), "../")
		call cursor(1,1)
endfunction

"================== Start ================
function! ftp#ftp#Ftpg()
		set nobackup
		set splitright
		cd $vim/vimfiles/autoload/ftp/tmp
		vsplit ./ftp
		set cursorline
		highlight CursorLine guibg=blue ctermbg=blue
		nnoremap <Home> :call <SID>MDf()<cr>
		nnoremap <Insert> :call <SID>RNf()<cr>
		nnoremap <del> :call <SID>Df()<cr>
		nnoremap <Enter> :call <SID>Gf()<cr>
		"============== Init =================
		cd ..
		" Reading a file.
		let s:fl = readfile("_ftprc", "b")
		let tt = s:fl[3]
		while tt != "cd /\r"
			let tm = strridx(tt, "/", len(tt) - 3)
			let tt = strpart(tt, 0, tm + 1)
			let tt = tt . "\r"
			call add(s:prevwd, tt)
		endwhile
		call reverse(s:prevwd)
"		let s:prevwd[0] = s:fl[3] "'cd /\r'
		if len(s:fl) == 1
				let acnt = [0, 0, 0, 0]
				let str = ["server", "user ID ", "password", 
										\ "remote dir"]
						for i in range(0, len(str)-1)
								let acnt[i] = input("Input FTP " . str[i] . " ")
								" No check ======================================
								if acnt[i] == ""
										return
								endif
								let acnt[i] = acnt[i] . "\r"
								if i == 0
										let acnt[i] = "open " . acnt[i]
								elseif i == 3
										let acnt[i] = "cd " . acnt[i]
								endif		
						endfor
				call extend(acnt, ['lcd "c:\Program files\vim\vimfiles\autoload\ftp\tmp"' . "\r"])
				call extend(acnt, ["ls\r", "disconnect\r", "bye"])
				call writefile(acnt, "_ftprc", "b")
		endif

		call s:Getlist()
		set splitbelow
		new ./ftp
		2winc w
		autocmd! BufWrite *.txt call ftp#ftp#Ftpput()
		autocmd! BufWrite *.cgi call ftp#ftp#Ftpput()
		autocmd! BufWrite *.py call ftp#ftp#Ftpput()
		autocmd! BufWrite *.ruby call ftp#ftp#Ftpput()
		autocmd! BufWrite *.pl call ftp#ftp#Ftpput()
		autocmd! BufWrite *.php call ftp#ftp#Ftpput()
		autocmd! BufWrite *.css call ftp#ftp#Ftpput()
		autocmd! BufWrite *.js call ftp#ftp#Ftpput()
		autocmd! BufWrite *.html call ftp#ftp#Ftpput()
		cd $vim/vimfiles/autoload/ftp/tmp
endfunction

function! ftp#ftp#Ftpwrite()
		cd "$Vim\vimfiles\autoload\ftp\tmp"
		w! "$Vim\vimfiles\autoload\ftp\tmp\%:t"
		3winc w
		1,$delete
		cd "$Vim\vimfiles\autoload\ftp"
		r !ftp -s:_ftprc
		call s:Cutspce()
		%call s:Snip('1111111')
		2winc w
		1,$delete
		let tmp = s:fl[5]
		let s:fl[5] = "ls\r"
		call writefile(s:fl, "_ftprc", "b")
		r !ftp -s:_ftprc
		let s:fl[5] = tmp
		call s:Getlist()
		1winc w

		autocmd VimLeave * call ftp#ftp#Ftpleave()
endfunction

function! ftp#ftp#Ftpput()
		cd $vim/vimfiles/autoload/ftp
		let ftp_myName=expand("%:t")
		if len(s:fl) >= 6
				call remove(s:fl, 5, len(s:fl)-1)
				call writefile(s:fl, "_ftprc", "b")
		endif
		call add(s:fl, "put " . expand(ftp_myName) . "\r")
		call add(s:fl, "disconnect" . "\r")
		call writefile(add(s:fl, "bye"), "_ftprc", "b")
		call ftp#ftp#Ftpwrite()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


