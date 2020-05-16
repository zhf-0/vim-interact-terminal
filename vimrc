" config for vim 8.1

nnoremap <leader>s V:call VisualSendToTerminal()<CR>
vnoremap <leader>s <Esc>:call VisualSendToTerminal()<CR>
vnoremap <leader>j <Esc>:call JustSend()<CR>

function! Get_visual_selection()
	"Shamefully stolen from http://stackoverflow.com/a/6271254/794380
	" Why is this not a built-in Vim script function?!
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	"return join(lines, "\n")
	return lines
endfunction


function! VisualSendToTerminal()
    let buff_n = term_list()
    if len(buff_n) > 0
        let buff_n = buff_n[0] " sends to most recently opened terminal
        let lines = Get_visual_selection()        
		let title = bufname(buff_n) 
		if  match(title,'!python') == 0   " python console
			let indent = match(lines[0], '[^ \t]') " check for removing unnecessary indent
			for l in lines
				if len(l) > 0
					let new_indent = match(l, '[^ \t]')
					if new_indent == 0
						call term_sendkeys(buff_n, l. "\<CR>")
					else
						call term_sendkeys(buff_n, l[indent:]. "\<CR>")
					endif
					sleep 10m
				endif
			endfor
			call term_sendkeys(buff_n,"\<CR>")
		elseif match(title,'!ipython') == 0  " ipython console
			"call term_sendkeys(buff_n, "%autoindent"." \<CR>")
			let indent = match(lines[0], '[^ \t]') 
			for l in lines
				if len(l) > 0
					let new_indent = match(l, '[^ \t]')
					if new_indent == 0
						call term_sendkeys(buff_n, l. "\<CR>")
					else
						call term_sendkeys(buff_n, l[indent:]. "\<CR>")
					endif
					call term_wait(buff_n)
				endif
			endfor
			call term_sendkeys(buff_n,"\<CR>")
			"call term_sendkeys(buff_n, "%autoindent"."\<CR>")
		else  "  others console
			for l in lines
				let new_indent = match(l, '[^ \t]')
				call term_sendkeys(buff_n, l[new_indent:]. "\<CR>")
				call term_wait(buff_n)
				"sleep 10m
			endfor 
		endif 
    endif
endfunction


function! JustSend()
    let buff_n = term_list()
    if len(buff_n) > 0
        let buff_n = buff_n[0] " sends to most recently opened terminal
        let line = Get_visual_selection()
		let length = len(line)
		if length == 1
			call term_sendkeys(buff_n, line[0])
			sleep 10m
		else 
			for l in range(0,length-2)
				if len(line(l)) > 0
					call term_sendkeys(buff_n, line[l]. "\<CR>")
					sleep 10m
				endif
			endfor
			call term_sendkeys(buff_n, line[length-1])
			sleep 10m
		endif
    endif
endfunction
