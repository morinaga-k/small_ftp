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
"				let s:fl[5] = "ls\r"
				call writefile(s:fl, "_ftprc", "b")
		else
		endif
		r !del /q /f "c:\Program Files\Vim\vimfiles\autoload\ftp\tmp\%:t"
		r !del /q /f $Vim\vimfiles\autoload\ftp\ftp
endfunction

function! s:Cutspce()
		let tmp = getline('.')
		let l = len(tmp)
		if l == 0
			delete
		endif
endfunction

" parm number {0 | 1 | 2} 
function! s:Threewinc(bl)
	3winc w
	1,$delete
	r !ftp -s:_ftprc
	%call s:Cutspce()
	%call s:Snip('1111111')
	call cursor(expand("G"), 1)
	if a:bl != 0
		call s:Getlist(a:bl)
	endif
	"call cursor(8,1)
endfunction

" chmod ====================================
function! s:PMf()
	let name = expand("<cfile>")
	let pm = input("change mode ")
	let s:fl[5] = "quote site chmod " . pm . " " . name
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(2)

endfunction

" rmdir ====================================
function! s:RMf()
	let rmres = input("delete this folder? y:n ")
	if rmres == "n"
		echo ""
		return
	endif
	let s:fl[5] = "rmdir " . expand("<cfile>")
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(1)
endfunction

" mkdir ===================================
function! s:MDf()
	let newdir = input("mkdir ")
	if newdir == ""
		return
	endif
	let s:fl[5] = "mkdir " . newdir . "\r"
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(1)
endfunction

" rename =================================
function! s:RNf()
	let oldname = expand("<cfile>")
	let newname = input("rename to ")
	if newname == ""
			return
	endif
	let ext = expand("<cfile>:e")

	if oldname =~ "[.]" && ext == " "
			let endp = stridx(oldname, ".")	
			let oldname = oldname[0: endp]
	endif
	if newname !~ "[.]" && ext != "" 
		let newname = newname . "." . ext
	endif
	
	let s:fl[5] = "rename " . oldname . " " . newname . "\r"
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(1)
endfunction

" del ==================================
function! s:Df()
	let dlres = input("delete this file? y:n ")
	if dlres == "n"
		echo ""
		return
	endif
	let dest = expand("<cfile>")
	let s:fl[5] = "del " . dest . "\r"
	call writefile(s:fl, "_ftprc", "b")
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
				silent call s:Getlist(1)
				return 
		endif

		let res = match(dest, "[.]")
		if res == -1
				call add(s:prevwd, s:fl[3])
				let s:fl[3] = s:fl[3][0: strlen(s:fl[3]) - 2]
				let s:fl[3] = s:fl[3] . dest . "\/\r"
				call writefile(s:fl, "_ftprc", "b")
				silent call s:Getlist(1)
				return
		endif

		cd $vim/vimfiles/autoload/ftp/tmp/
		3winc w
		r !del *.txt *.cgi *.html
		cd $vim/vimfiles/autoload/ftp
		let s:fl = readfile("_ftprc", "b")
		if len(s:fl) >= 7
				call remove(s:fl, 5, len(s:fl)-1)
				" no need below.
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
		if pass !~ -1
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

function! s:Getlist(bl)
		2winc w
		silent 1,$delete
		if a:bl == 1
			let s:fl[5] = "ls\r"
  	elseif a:bl == 2
			let s:fl[5] = "ls -l\r"
	  else 
			let s:fl[5] = "ls\r"
		endif
	"	call extend(s:fl, ["verbose\r"], 5)
		silent call writefile(s:fl, "_ftprc", "b")
		cd $vim/vimfiles/autoload/ftp
		silent r !ftp -s:_ftprc
		%s///g
		%call s:Snip('^\.')
		call cursor(expand("$"),1)
		for i in range(1,3)
				delete
		endfor
		let tm = getline(0, line("$"))
		if len(tm) >= 13 
			silent 1,13delete
	  else 
			silent 1,12delete
		endif
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
		nnoremap <F5> :call <SID>PMf()<cr>
		nnoremap <F4> :call <SID>RMf()<cr>
		nnoremap <F3> :call <SID>MDf()<cr>
		nnoremap <F2> :call <SID>RNf()<cr>
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
		if len(s:fl) == 1
				let acnt = [0, 0, 0, 0]
				let str = ["server", "user ID ", "password", 
										\ "remote dir"]
						for i in range(0, len(str)-1)
								let acnt[i] = input("Input FTP " . str[i] . " ")
								" No check below ======================================
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

		call s:Getlist(1)
		set splitbelow
		new ./ftp
		1winc w
		cd $vim/vimfiles/autoload/ftp/tmp
		2winc w
		cd $vim/vimfiles/autoload/ftp/tmp
		autocmd! BufWrite *.txt call ftp#ftp#Ftpput()
		autocmd! BufWrite *.cgi call ftp#ftp#Ftpput()
		autocmd! BufWrite *.py call ftp#ftp#Ftpput()
		autocmd! BufWrite *.ruby call ftp#ftp#Ftpput()
		autocmd! BufWrite *.pl call ftp#ftp#Ftpput()
		autocmd! BufWrite *.php call ftp#ftp#Ftpput()
		autocmd! BufWrite *.css call ftp#ftp#Ftpput()
		autocmd! BufWrite *.js call ftp#ftp#Ftpput()
		autocmd! BufWrite *.html call ftp#ftp#Ftpput()
endfunction

function! ftp#ftp#Ftpwrite()
		" save ================
		cd $Vim\vimfiles\autoload\ftp\tmp
		"cd "$Vim\vimfiles\autoload\ftp\tmp\"
		w "%:t"
		w! "%:t"
		"w "$Vim\vimfiles\autoload\ftp\tmp\%:t"
		"w! "$Vim\vimfiles\autoload\ftp\tmp\%:t"
		" put =================
		3winc w
		silent 1,$delete
		cd $Vim\vimfiles\autoload\ftp
		r !ftp -s:_ftprc
		%call s:Snip('1111111')
		silent %call s:Cutspce()
		" ls ==================
		2winc w
		silent 1,$delete
		let tm = s:fl[5]
		let s:fl[5] = "ls\r"
		call writefile(s:fl, "_ftprc", "b")
		r !ftp -s:_ftprc
		let s:fl[5] = tm
		silent call s:Getlist(1)
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
		silent call ftp#ftp#Ftpwrite()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


