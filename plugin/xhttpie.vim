
" nmap <leader>xh :call xhttpie#run()<CR>
" vmap <leader>xh :call xhttpie#run()<CR>

if !exists(':XHttp')
    command! -nargs=0 -range XHttp :call xhttpie#run()
    map <unique> <script> <Plug>XHttp :XHttp<CR>
    "nmap <unique> <script> <Plug>XHttp :XHttp<CR>
    "xmap <unique> <script> <Plug>XHttp :XHttp<CR>
endif
