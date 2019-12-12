" config for vim 8.1

nnoremap <leader>s V:call VisualSendToTerminal()<CR>
vnoremap <leader>s <Esc>:call VisualSendToTerminal()<CR>

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
		let indent = match(lines[0], '[^ \t]') " check for removing unnecessary indent
        for l in lines
            let new_indent = match(l, '[^ \t]')
            if new_indent == 0
                call term_sendkeys(buff_n, l. "\<CR>")
            else
                call term_sendkeys(buff_n, l[indent:]. "\<CR>")
            endif
            sleep 10m
        endfor
    endif
endfunction

