command! -range=% -nargs=* Mysql call mysql#Query(<line1>, <line2>, 0, <f-args>)
command! -range=% -nargs=* MysqlPretty call mysql#Query(<line1>, <line2>, 1, <f-args>)
command! -range=% MysqlFormat call mysql#format(<line1>, <line2>)

noremap ;r :Mysql<CR>
noremap <F2> :call mysql#tables()<CR>
noremap ;d :call mysql#describe()<CR>
