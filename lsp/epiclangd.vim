" -----------------
"  EpiClang parser
" ----------------
" Run epiclang in the current buffer to get coding style errors only
" These commands are not written in the file and a temp file is used.
" Dependencies:
" - 'epiclang' (aka clang + epitech-plugin-banana.so)

let s:name="epiclangd"
let s:version="v1"

let s:base_cmd="epiclang"
let s:base_cflags="-Wno-everything -fsyntax-only"
let s:compile_flags_file="compile_flags.txt"

fun! s:Parse()
    if !LspIsEnabled(s:name)
        au! Lsp_epiclangd
    endif
    if expand('%:e') != 'c' && expand('%:e') != 'h'
        return 0
    endif
    let tmp_file = ".epiclang_".expand('%:t')
    exec 'silent w!' tmp_file
    let flags = filereadable(s:compile_flags_file) ? readfile(s:compile_flags_file) : []
    let compile_flags = empty(flags) ? "" : substitute(join(flags, " "), ";", "\\\\;", "g")
    let cmd = s:base_cmd." ".s:base_cflags." ".compile_flags." ".tmp_file." 2>&1 | grep '".tmp_file.":[0-9]*:[0-9]*: warning\\: \\[Banana\\] ' | sed 's%".tmp_file.":\\([0-9]*\\):[0-9]*: warning: \\[Banana] \\[\\(.*\\)\\] \\(.*\\) (\\(C-.*\\))%\\1:\\2###\\4: \\3%'"
    let content = split(system(cmd), "\n")
    exec 'silent !rm -f ' tmp_file
    if empty(content) || len(content[0]) < 1
        return 0
    endif
    for line in content
        let num = split(line, ":")[0]
        let type = split(line, ":")[1] == "Major" ? g:LspError : g:LspWarning
        let msg = split(line, "###")[1]
        call LspDisplayLine(num, type, msg)
    endfor
    return 0
endfun

augroup Lsp_epiclangd
    au!
    au InsertLeave,BufReadPost,BufWritePost *.c,*.h call s:Parse()
aug end

call s:Parse()
