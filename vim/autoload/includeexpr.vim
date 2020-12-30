" `fname` is the modified file name with forward slashes.
" `additional_paths` is where we look for files.
function includeexpr#find(fname, additional_paths)
    let l:path_parts = split(a:fname, "/")

    let l:search_paths = []
    call extend(l:search_paths, a:additional_paths)
    call extend(l:search_paths, split(&path, ','))
    call extend(l:search_paths, split(&l:path, ','))

    let l:files = []
    for search_path in l:search_paths
        let l:gpath = globpath(search_path . "/" . join(l:path_parts[0:-2], "/"),
                    \ l:path_parts[-1] . "*", v:true)
        call extend(l:files, split(l:gpath, "\n"))
    endfor

    if empty(l:files)
        let l:taglist = taglist(a:fname)
        if !empty(l:taglist)
            let l:tagfiles = tagfiles()
            for item in l:taglist
                for tagfile in l:tagfiles
                    let l:tf = substitute(fnamemodify(tagfile, ":h") . "/", "\\", "/", "g")
                    let l:filename_modified = substitute(item.filename, "\\", "/", "g")
                    let l:filename_modified = expand(substitute(l:filename_modified, l:tf, "", "g"))
                    if l:filename_modified != item.filename
                        break
                    endif
                endfor

                call add(l:files, l:filename_modified)
            endfor
        endif
    endif

    call map(l:files, 'glob(v:val)')
    call filter(l:files, '!empty(v:val)')
    call uniq(l:files)

    if len(l:files) > 1
        let l:prompt = join(map(copy(l:files), 'v:key + 1 . ": " . v:val'), "\n")
        let l:prompt .= "\nSelect (Default 1): "
        let l:selection = str2nr(input(l:prompt))
        return l:files[l:selection - 1]
    elseif len(l:files) == 1
        return l:files[0]
    endif

    return a:fname
endfunction
