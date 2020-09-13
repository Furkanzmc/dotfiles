command! -nargs=? StartReview :call git#start_review(<f-args>)
command! ReviewDiff :call git#review_diff()
command! FinishReview :call git#finish_review()
