" ----------------------
"  Coding style checker
" ----------------------
" Run BANANA in the current workspace and add comments if coding style violations are found
" These comments are not written in the file and a temp file is used.
" Dependencies:
" - 'vera++' with Epitech config
" - 'cscheck' and bash scripts


let s:name="banana"
let s:version="v2"

fun! s:Check()
    if !LspIsEnabled(s:name)
        au! Lsp_csc
    endif
    if expand('%:e') != 'c' && expand('%:e') != 'h'
        return 0
    endif
    let tmp_file = expand('%:h')."/csc_".expand('%:t')
    exec 'silent w!' tmp_file
    let content = split(system("sed -i \"s/    \\/\\/x\\\\\\.*//g\" ".tmp_file."; sed -i \"s/    \\/\\/\\!\\\\\\.*//g\" ".tmp_file."; cscheck ".tmp_file), "\n")
    exec 'silent !rm -f ' tmp_file
    if len(content) < 1
        return 0
    endif
    for line in content
        let num = split(line, ":")[0]
        let type = (split(line, ":")[1] == "MINOR") ? g:LspWarning : g:LspError
        let msg = "C-".split(line, ":C-")[1]
        call LspDisplayLine(num, type, msg)
    endfor
    return 0
endfun

augroup Lsp_csc
    au!
    au InsertLeave,BufReadPost,BufWritePost *.c,*.h call s:Check()
aug end

call s:Check()
