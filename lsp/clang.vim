" --------------
"  Clang parser
" --------------
" Run clang in current buffer to get coding style errors
" These commands are not written in the file and a temp file is used.
" Dependencies:
" - 'clang'


let s:name="clang"
let s:version="v1"

fun! s:read_flags()
    try
        return readfile("compile_flags.txt")
    catch /E484/
    endtry
    return [""]
endfun

fun! s:Parse()
    if !LspIsEnabled(s:name)
        au! Lsp_clang
    endif
    if expand('%:e') != 'c' && expand('%:e') != 'h'
        return 0
    endif
    let tmp_file = expand('%:h')."/clang_".expand('%:t')
    exec 'silent w!' tmp_file
    let flags = s:read_flags()
    let compile_flags = substitute(join(flags, " "), ";", "\\\\;", "g")
    let content = split(system("clang -fsyntax-only ".compile_flags." ".tmp_file." 2>&1 | grep \"".tmp_file.":[0-9]*:[0-9]*: warning\\|".tmp_file.":[0-9]*:[0-9]*: error\" | sed \"s/ \\\[-.*\\\]//\""), "\n")
    exec 'silent !rm -f ' tmp_file
    if empty(content) || len(content[0]) < 1
        return 0
    endif
    for line in content
        let num = split(line, ":")[1]
        let type = (split(line, ":")[3] == " error") ? g:LspError : g:LspWarning
        let msg = split(line, ": ")[2]
        call LspDisplayLine(num, type, msg)
    endfor
    return 0
endfun

augroup Lsp_clang
    au!
    au InsertLeave,BufReadPost,BufWritePost *.c,*.h call s:Parse()
aug end

call s:Parse()
