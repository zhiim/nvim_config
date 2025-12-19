if exists("b:current_syntax")
  finish
endif

" files changed
syn match gitlogFiles /^\s*\d\+\s\+files\?/ contains=gitlogFileCount
syn match gitlogFileCount /\d\+/ contained

" commit hash
syn match gitlogHash /|\s*\zs[0-9a-f]\{7,8\}\ze\s/

" HEAD and branch info
syn match gitlogRef /([^)]\+)/ contains=gitlogHead,gitlogBranch,gitlogRemote
syn match gitlogHead /HEAD\s*->/ contained
syn match gitlogBranch /master\|main/ contained
syn match gitlogRemote /origin\/[^,)]\+/ contained

" commit message
syn match gitlogMessage /)\s\+\zs.\{-}\ze\s\+<[^>]\+>/
syn match gitlogMessage /[0-9a-f]\{7,8\}\s\+\zs[^(<].\{-}\ze\s\+<[^>]\+>/

" author name
syn match gitlogAuthor /<[^>]\+>/ nextgroup=gitlogTime skipwhite

" time
syn match gitlogTime /.\+$/ contained

hi def link gitlogFileCount Number
hi def link gitlogHash Identifier
hi def link gitlogHead Special
hi def link gitlogBranch Type
hi def link gitlogRemote Constant
hi def link gitlogMessage String
hi def link gitlogAuthor Keyword
hi def link gitlogTime Comment

let b:current_syntax = "git-commit-log"
