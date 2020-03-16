let s:SQLBIN = trim(system("which mysql"))
let s:db_alias_file = stdpath('config') . "/vim-sql/db_alias"
let s:result_buf = '__query_results__'
let s:KEYWORDS = ['SELECT', 'FROM', 'INTO', 'TABLE', 'ON', 'AS', 'DELETE', 'CREATE', 'WHERE', 'IN', 'GROUP', 'BY', 'ORDER']
let s:INDENT_KEYWORDS = ['SELECT', 'FROM', 'CREATE', 'WHERE', 'DELETE', 'GROUP', 'BY', 'ORDER']

function! s:Alias(alias)
    let alias_list = readfile(s:db_alias_file)
    for a in alias_list
        let alias_data = split(a, ",")
        if alias_data[0] == a:alias
            return { 'alias': alias_data[0],
            \ 'schema': alias_data[1],
            \ 'db': alias_data[2],
            \ 'db_url': alias_data[3],
            \ 'port': alias_data[4],
            \ 'user': alias_data[5],
            \ 'pass': alias_data[6],
            \ }
        endif
    endfor
    return -1
endfunction

function! s:detect_alias()

    let dir = split(getcwd(), "/")[-1]
    let alias_list = readfile(s:db_alias_file)
    for a in alias_list
        let alias_data = split(a, ",")
        if alias_data[0] == dir
            return dir
        endif
    endfor
    return -1

endfunction

function! s:close_buffer(buf_name)
    if bufexists(expand(a:buf_name)) == 1
        let wid = bufwinid(bufnr(a:buf_name))
        if wid > -1
            call win_gotoid(wid)
            wincmd q
        endif
    endif
endfunction

function! s:format_lines(l1, l2)
    let lines = getline(a:l1, a:l2)
    for l in range(0, len(lines)-1)
        let words = split(lines[l])
        for w in range(0, len(words)-1)
            let word = words[w]

            let is_keyw = match(s:KEYWORDS, toupper(word))
            if  is_keyw > -1
                let words[w] = toupper(word)
            endif

        endfor
        let lines[l] = join(words, " ")
    endfor
    return lines
endfunction

function! s:format_mysql(l1, l2)
    let formatted_text = s:format_lines(a:l1, a:l2)
    for l in range(a:l1, a:l2)
        call setline(l, formatted_text[l-a:l1])
    endfor
endfunction

function! s:Mysql(l1, l2, ...)

    let alias = s:detect_alias()
    if alias > -1
        let data = s:Alias(alias)
    elseif a:0 > 0
        let data = s:Alias(a:1)
    else
        return
    endif

    call s:close_buffer(s:result_buf)

    let script = join(getline(a:l1, a:l2), "\n")

    let call = join([s:SQLBIN,
                \ "--user=" . data["user"],
                \ "--password=" . data["pass"],
                \ "--port=" . data["port"],
                \ "--host=" . data["db_url"],
                \ "--column-names", "--batch",
                \ '--execute="' . script . '"',
                \ data["schema"],
                \ ], " ")

    let results = systemlist(call)
    if len(results) > 0
        exec "botright 7split " . s:result_buf
        setlocal buftype=nofile
        normal! ggdG
        " Insert the bytecode.
        call append(0, results)
        normal! gg"Zdd
    endif

endfunction

function! EditAlias()
    exec "top split " . s:db_alias_file
endfunction

command! -range=% -nargs=? Mysql call s:Mysql(<line1>, <line2>, <q-args>)
command! -range=% FormatSQL call s:format_mysql(<line1>, <line2>)
