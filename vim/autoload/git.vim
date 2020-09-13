let s:base_branch = ""

function! git#start_review(...)
    let l:base_branch = ""
    if (strlen(s:base_branch) > 0)
        let l:base_branch = s:base_branch
    else
        if (a:0 == 0)
            echoerr "Base branch is required."
            return
        endif

        let l:base_branch = a:1
        let s:base_branch = a:1
    endif

    execute 'args `git diff --name-only ' . l:base_branch . '`'

    if mapcheck("<leader>gr", "n") == ""
        nmap <silent> <leader>gr :ReviewDiff<CR>
    endif
endfunction

function! git#review_diff()
    if (strlen(s:base_branch) == 0)
        echoerr "Start a review using StartReview"
        return
    endif

    execute 'Gdiff ' . s:base_branch
endfunction

function! git#finish_review()
    if mapcheck("<leader>gr", "n") != ""
        nunmap <leader>gr
    endif
endfunction
