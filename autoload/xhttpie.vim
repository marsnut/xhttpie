
let s:displayBufName = '_xMonitor_'

func! s:checkSetting()
    if !exists('g:xhttpie_viewsize') || !exists('g:xhttpie_log_file')
        echom 'viewsize or log file no setting'
        return 0
    endif
    return 1
endfunc

function! s:get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - 2]
    " let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, '\n')
endfunction

function s:OpenResultBuf()
    if bufwinnr(displayBufName)  == -1
        execute 'below ' . g:xhttpie_viewsize . '16split ' . s:displayBufName
        nnoremap  q :q
        setlocal filetype=DisplayTrans
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal nolist
        setlocal nobuflisted
        setlocal nocursorline
        " setlocal nonumber
        setlocal norelativenumber
        setlocal winfixwidth

        setlocal nobuflisted
        setlocal nowrap
        setlocal nomodified
        " Reload buffer automatically if it has changed outside of
        " this Vim session
        setlocal autoread
    else
        execute bufwinnr(displayBufName) . "wincmd w"
    endif
endfunction

function s:HandleResult(channel) abort
    let text = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let text += [ch_read(a:channel)]
    endwhile
    let result = join(text, '')
    " let data = join(text, '')
    " let result = system('!( echo "' . data . '"|jq . )&')
    " echom result
   
    call s:OpenResultBuf()

    " normal! ggdG
    normal! Go
    " normal! Go.variable
    
    silent put = result
    let lineno = line('.')
    execute lineno . '!jq'
    normal! zt

    " silent 1,1delete
    execute winnr("#") . "wincmd w"
endfunction

function! xhttpie#run()
    if s:checkSetting() == 0
        return
    endif

    let http_cmd = s:get_visual_selection()
    call s:OpenResultBuf()
    normal! Go
    silent put = '// -----------------------------------------------------'
    silent put = '// ' . http_cmd
    silent put = '// -----------------------------------------------------'
    execute winnr("#") . "wincmd w"

    let job = job_start(['sh', '-c', '! ' . http_cmd . ' --ignore-stdin &'], #{close_cb: 's:HandleResult'})
    echom job_status(job)
endfunction

function xhttpie#logview()
    if s:checkSetting() == 0
        return
    endif
    
    let job = job_start('tail -f ' . g:xhttpie_log_file,
                         \ {'out_io': 'buffer', 'out_name': '_xMonitor_'})
endfunction

