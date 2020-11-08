command! -nargs=1 -complete=file SourceEnv :call dotenv#source(<f-args>)
command! -nargs=1 -complete=file DeactivateEnv :call dotenv#deactivate(<f-args>)
