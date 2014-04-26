scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:fin=1
let s:cwd="/cgi/\r"
let s:fl = []
let s:prevwd = ["cd /"]
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
		let tmp = getline('.')
		let l = len(tmp)
		if l == 0
			delete
		endif
endfunction

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
endfunction

function! s:Seekhead(name)
	let lines = getline(0, line("$"))
	let res = 0
	let i = 0
	let l = len(lines)
	while i < l
		let sc = split(lines[i])
		if sc[0] =~ a:name
			call cursor(i + 1, 1)
			return 
		endif
		let i += 1
	endwhile
endfunction

function! s:Chget(filename)
		cd $vim/vimfiles/autoload/ftp/tmp/
		3winc w
		r !del *.txt *.cgi *.html
		cd $vim/vimfiles/autoload/ftp
		let s:fl = readfile("_ftprc", "b")
		if len(s:fl) >= 7
				call remove(s:fl, 5, len(s:fl)-1)
				call writefile(s:fl, "_ftprc", "b")
		endif
		call add(s:fl, "get " . a:filename . "\r")
		call add(s:fl, "disconnect\r")
		call add(s:fl, "bye")
		call writefile(s:fl, "_ftprc", "b")
endfunction

function! ftp#ftp#MCf()
endfunction

" copy =====================================
function! ftp#ftp#CPf()
	
endfunction

" reverse ==================================
function! ftp#ftp#RVf()
	let lines = getline(0, line("$"))
	call reverse(lines)
	for i in range(len(lines))
		call setline(i, lines[i])
	endfor
endfunction

" sort =====================================
function! ftp#ftp#STf()
	let lines = getline(0, line("$"))
	call sort(lines)
	for i in range(len(lines))
		call setline(i, lines[i])
	endfor
endfunction

" chmod ====================================
function! ftp#ftp#PMf()
	let name = expand("<cfile>")
	silent call s:Getlist(2)
	call s:Seekhead(name)
	redraw!

	let pm = input(name . " change mode ")
	if pm == ""
		return
	endif
	let s:fl[5] = "quote site chmod " . pm . " " . name
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(2)
	call s:Seekhead(name)
endfunction

" rmdir ====================================
function! ftp#ftp#RMf()
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
function! ftp#ftp#MDf()
	let newdir = input("mkdir ")
	if newdir == ""
		return
	endif
	let s:fl[5] = "mkdir " . newdir . "\r"
	call writefile(s:fl, "_ftprc", "b")
	silent call s:Threewinc(1)
endfunction

" rename =================================
function! ftp#ftp#RNf()
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
function! ftp#ftp#Df()
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

function! ftp#ftp#Gf()
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

		call s:Chget(dest)

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
		if res != -1	
				delete
		endif
endfunction

function! s:Getlist(bl)
		" ls =====================
			2winc w
			let detflg = 0
		if a:bl != 3
			silent 1,$delete
			if a:bl == 2
				let s:fl[5] = "ls -l\r"
				let detflg = 1
		  else 
				let s:fl[5] = "ls\r"
			endif
			cd $vim/vimfiles/autoload/ftp
			silent call writefile(s:fl, "_ftprc", "b")
		endif
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
		if detflg == 1
			let lines = getline(0, line("$"))
			let i = 0
			for line in lines
				let lst = split(line)
				call reverse(lst)
				echo "len is " . len(lst)
				call remove(lst, 1, len(lst) - 2)
				let str = join(lst, " ")
				call setline(i, str)
				let i += 1
				redraw
			endfor
			1,2delete
			$delete
		endif
		call setline(expand("$"), "../")
		if detflg != 1
			call cursor(1,1)
		endif
		redraw!
endfunction

"================== Start ================
function! ftp#ftp#Ftpg()
		set nobackup
		set splitright
		cd $vim/vimfiles/autoload/ftp/tmp
		vsplit ./ftp
		set cursorline
		highlight CursorLine guibg=blue ctermbg=blue
	"	noremap <silent> <unique> <F5> :call <SID>PMf()<cr>
	"	noremap <silent> <unique> <F4> :call <SID>RMf()<cr>
	"	noremap <silent> <unique> <F3> :call <SID>MDf()<cr>
	"	noremap <silent> <unique> <F2> :call <SID>RNf()<cr>
	"	noremap <silent> <unique> <del> :call <SID>Df()<cr>
	"	noremap <silent> <unique> <Enter> :call <SID>Gf()<cr>
		"============== Init =================
		cd ..
		" Reading a file.
		let s:fl = readfile("_ftprc", "b")
		let ll = len(s:fl)
		if ll != 1
			let tt = s:fl[3]
			while tt != "cd /\r"
				let tm = strridx(tt, "/", len(tt) - 3)
				let tt = strpart(tt, 0, tm + 1)
				let tt = tt . "\r"
				call add(s:prevwd, tt)
			endwhile
			call reverse(s:prevwd)
		endif
		if ll == 1
				let s:fl = [0, 0, 0, 0]
				let str = ["server", "user ID", "password", "cd"]
						for i in range(0, len(str)-1)
								let s:fl[i] = input("Input FTP " . str[i] . " ")
								if s:fl[i] == ""
										return
								endif
								if i == 0
										let s:fl[i] = "open " . s:fl[i]
								elseif i == 3
										let ss = match(s:fl[i], "^cd")
										if ss == -1
											let s:fl[i] = "cd " . s:fl[i]
										endif
								endif		
								let s:fl[i] = s:fl[i] . "\r"
						endfor
				call add(s:fl, 'lcd "c:\Program files\vim\vimfiles\autoload\ftp\tmp"' . "\r")
				"call extend(s:fl, ['lcd "c:\Program files\vim\vimfiles\autoload\ftp\tmp"' . "\r"])
				call extend(s:fl, ["ls\r", "disconnect\r", "bye"])
				call writefile(s:fl, "_ftprc", "b")
		endif

		set splitbelow
		new ./ftp
		call s:Getlist(3)
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


