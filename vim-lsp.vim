" ------------------------------
"  Vim Language Server Protocol
" ------------------------------
" Display info comments in current buffer.
" LSPs must be in 'lsp' folder and be in Vimscript (.vim) format
" Also, this is not a language server protocol, it just uses shell calls
"

let s:root="~/.vim/"
let s:lspconfig = glob(s:root)."/lspconfig"

let g:LspWarning = "!\\"
let g:LspError = "x\\"
let g:EnabledLsp = ""

fun! LspDisplayLine(line, type, message)
    call setline(a:line, getline(a:line)."    //".a:type." ".a:message)
    call LspUpdateDisplay()
endfun

fun! LspUpdateDisplay()
    hi LspWarningColor ctermfg=224 gui=bold guifg=#dbb671
    hi LspErrorColor ctermfg=15 ctermbg=1 gui=bold guifg=#de5d68
    syn match LspWarningColor /\/\/\!\\ .*[ ]*/
    syn match LspErrorColor /\/\/x\\ .*[ ]*/
    redraw!
endfun

fun! LspClearLines()
    keeppatterns %s/\s*\/\/!\\\ .*$//e
    keeppatterns %s/\s*\/\/x\\\ .*$//e
endfun

fun! LspAdd(name)
    let g:EnabledLsp .= (g:EnabledLsp != "" ? ", " : "").a:name
endfun

fun! LspIsEnabled(name)
    return stridx(g:EnabledLsp, a:name) > -1
endfun

fun! LspStart(...)
    if a:0 < 1
        return 0
    endif
    call LspClearLines()
    let args = a:000
    for arg in args
        let file = glob(s:root)."/lsp/".arg.".vim"
        if !filereadable(file)
            echoerr "Lsp '".arg."'not found"
        else
            call LspAdd(arg)
            exec 'source' file
            redraw!
        endif
    endfor
endfun

fun! LspStop(...)
    if (a:0 < 1)
        let g:EnabledLsp = ""
    else
        let args = a:000
        for arg in args
            let g:EnabledLsp = substitute(substitute(g:EnabledLsp, arg, '', ''), ', , ', ', ', 'g')
        endfor
    endif
    call LspClearLines()
endfun

fun! LspWriteConfig()
    call writefile(split(g:EnabledLsp, (stridx(g:EnabledLsp, ", ") < 0 ? "" : ", "), 1), s:lspconfig, 'b')
endfun

fun! LspReadConfig()
    if !filereadable(s:lspconfig)
        return 0
    endif
    let content = readfile(s:lspconfig)
    if len(content) < 1
        return 1
    endif
    for i in range(0, len(content) - 1)
        call LspStart(content[i])
    endfor
endfun

func! LSPMenu(id, index)
    if (a:index == 1)
        let lsps = input('Enter lsp name(s): ')
        if empty(lsps)
            return 0
        elseif lsps == "*"
            call LspStart()
        else
            call LspStart(split(lsps, " "))
        endif
    endif
    if (a:index == 2)
        let lsps = input('Enter lsp name(s): ')
        if empty(lsps)
            return 0
        elseif lsps == "*"
            call LspStop()
        else
            call LspStop(split(lsps, " "))
        endif
    endif
    if (a:index == 3)
        call LspClearLines()
    endif
    if (a:index == 4)
        exec '!open https://github.com/man-google/vim-lsp &' | redraw!
    endif
endfunc

command! LspMenu call popup_menu(['Enable LSP', 'Disable LSP', 'Clear messages', 'GitHub repo & help'],
     \ #{ title: " LSP ", callback: 'LSPMenu', line: 25, col: 40,
     \ highlight: 'Question', border: [], close: 'click',  padding: [1,1,0,1]} )

command! -nargs=* LspStart call LspStart(<f-args>)
command! -nargs=* LspStop call LspStop(<f-args>)

augroup Lsp
    au!
    au VimEnter * call LspReadConfig()
    au VimLeave * call LspWriteConfig()
    au InsertEnter,BufWritePre * call LspClearLines()
aug END

call SetAlias('lsp', 'LspMenu')
