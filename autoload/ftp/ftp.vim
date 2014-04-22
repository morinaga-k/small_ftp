scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:fin=1
let s:cwd="/cgi/"

function! ftp#ftp#Ftpleave()
		if s:fin == 1
				let fl = readfile("_ftprc", "b")
				let fl[3] = "cd " . s:cwd . "\r"
				call writefile(fl, "_ftprc", "b")
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

function! s:Gf()
		if getcwd() != "$vim/vimfiles/autoload/ftp"
				cd $vim/vimfiles/autoload/ftp
		endif
		let fl = readfile("_ftprc", "b")
		let dest = expand("<cfile>")
		let res = match(dest, "../")
		if res != -1
				if fl[3] == "cd /"
						return
				endif
				let endslash = strridx(fl[3], "/", 3)
				let fl[3] = strpart(fl[3], 0, endslash + 1) 
				let fl[3] = fl[3] . "\r"
				call writefile(fl, "_ftprc", "b")
				2winc w
				1,$delete
				call s:Getlist()
				return 
		endif

		let res = match(dest, "[.]")
		if res == -1
				let fl[3] = fl[3][0: strlen(fl[3]) - 2]
				let fl[3] = fl[3] . dest . "\/\r"
				call writefile(fl, "_ftprc", "b")
				call s:Getlist()
				return
		endif

		cd $vim/vimfiles/autoload/ftp/tmp/
		3winc w
		r !del *.txt *.cgi *.html
		cd $vim/vimfiles/autoload/ftp
		let fl = readfile("_ftprc", "b")
		if len(fl) >= 7
				call remove(fl, 5, len(fl)-1)
				call writefile(fl, "_ftprc", "b")
		endif
		call add(fl, "get " . dest . "\r")
		call add(fl, "disconnect\r")
		call add(fl, "bye")
		call writefile(fl, "_ftprc", "b")
		3winc w
		1,$delete
		r !ftp -s:_ftprc
		call s:Cutspce()
		%call s:Snip('1111111')
		call cursor(expand("G"), 1)
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
		if res != -1						" If match an argument.
				delete
		endif
endfunction

function! s:Getlist()
		2winc w
		1,$delete
		let fl = readfile("_ftprc", "b")
		let fl[5] = "ls\r"
		call writefile(fl, "_ftprc", "b")
		r !ftp -s:_ftprc
		%s///g
		%call s:Snip('^\.')
		call cursor(expand("$"),1)
		for i in range(1,3)
				delete
		endfor
		1,13delete
		%call s:Snip('^\.')
		call setline(expand("$"), "../")
		call cursor(1,1)
endfunction

function! ftp#ftp#Ftpg()
		set nobackup
		set splitright
		cd $vim/vimfiles/autoload/ftp/tmp
		vsplit ./ftp
		set cursorline
		highlight CursorLine guibg=blue ctermbg=blue
		nnoremap <Enter> :call <SID>Gf()<cr>
		"============== Init =================
		cd ..
		let fl = readfile("_ftprc", "b")
		if len(fl) == 1
				let acnt = [0, 0, 0, 0]
				let str = ["server", "user ID ", "password", 
										\ "remote dir"]
						for i in range(0, len(str)-1)
								let acnt[i] = input("Input FTP " . str[i] . " ")
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
		let fl = readfile("_ftprc", "b")
		let tmp = fl[5]
		let fl[5] = "ls\r"
		call writefile(fl, "_ftprc", "b")
		r !ftp -s:_ftprc
		let fl[5] = tmp
		call s:Getlist()
		1winc w

		autocmd VimLeave * call ftp#ftp#Ftpleave()
endfunction

function! ftp#ftp#Ftpput()
		cd $vim/vimfiles/autoload/ftp
		let ftp_myName=expand("%:t")
		let fl = readfile("_ftprc", "b")
		if len(fl) >= 6
				call remove(fl, 5, len(fl)-1)
				call writefile(fl, "_ftprc", "b")
		endif
		call add(fl, "put " . expand(ftp_myName) . "\r")
		call add(fl, "disconnect" . "\r")
		call writefile(add(fl, "bye"), "_ftprc", "b")
		call ftp#ftp#Ftpwrite()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


