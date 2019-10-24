command! -nargs=0 TrexFlush lua require("trex").flush()
command! -nargs=0 TrexClearHistory lua require("trex").clear_history()
command! -nargs=0 TrexNext lua require("trex").next()
command! -nargs=0 TrexPrev lua require("trex").previous()
command! -nargs=0 TrexReset lua require("trex").reset()
command! -nargs=0 TrexInvoke lua require("trex").invoke()
command! -nargs=? TrexAttach lua require("trex").attach(<f-args>)

" TODO Remove in favor of luacmd
autocmd Filetype clojure nmap <buffer> <leader>so :lua require ("trex").fts.clojure.fn.require_ns()<CR>
autocmd Filetype clojure nmap <buffer> <leader>si :lua require ("trex").fts.clojure.fn.lein_import()<CR>
autocmd Filetype clojure nmap <buffer> <leader>sr :lua require ("trex").fts.clojure.fn.lein_require_current_file()<CR>
autocmd Filetype clojure nmap <buffer> <leader>sn :lua require ("trex").fts.clojure.fn.switch_ns()<CR>
autocmd Filetype clojure nmap <buffer> <leader>su :lua require ("trex").fts.clojure.fn.switch_to_user_ns()<CR>
autocmd Filetype clojure nmap <buffer> <leader>ss :lua require ("trex").fts.clojure.fn.lein_send()<CR>
autocmd Filetype clojure nmap <buffer> <leader>st :lua require ("trex").fts.clojure.fn.test_current_file()<CR>

autocmd Filetype clojure vnoremap <buffer> <leader>sv :lua require ("trex").fts.clojure.fn.lein_send_visual()<CR>
