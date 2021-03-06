" config for vim 8.1

nnoremap <leader>s V:call VisualSendToTerminal()<CR>
vnoremap <leader>s <Esc>:call VisualSendToTerminal()<CR>
vnoremap <leader>j <Esc>:call JustSend()<CR>
command Ip3 terminal ipython3 --no-autoindent
command P3 terminal python3

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
			let block_flag = 0
			for l in lines
				if len(l) > 0
					let res1 = matchstr(l,'\v if|for|def|with|class|while|try')
					let res2 = matchstr(l,'\v else|elif|except|finally')
					let new_indent = match(l, '[^ \t]')
					
					if new_indent == indent
						if block_flag == 0 && res1 != ''  " the begin of block
							let block_flag = 1
						elseif block_flag == 1 && res1 != '' " two continue blocks
							call term_sendkeys(buff_n,"\<CR>")
							call term_wait(buff_n)
						elseif  block_flag == 1 && res1 == '' && res2 == '' " the end of block, must ensure res2 = '',otherwise the block will be broken 
							call term_sendkeys(buff_n,"\<CR>")
							let block_flag = 0
							call term_wait(buff_n)
						endif
					endif

					call term_sendkeys(buff_n, l[indent:]. "\<CR>")
					call term_wait(buff_n)
				endif
			endfor
			call term_sendkeys(buff_n,"\<CR>")
		elseif match(title,'!ipython') == 0  " ipython console
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
		else  "  others console
			for l in lines
				let new_indent = match(l, '[^ \t]')
				call term_sendkeys(buff_n, l[new_indent:]. "\<CR>")
				call term_wait(buff_n)
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
