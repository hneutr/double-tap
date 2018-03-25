""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Double-Tap makes annoying comments and list items go away
" Maintainer:  Hunter Wapman <hunter.wapman@gmail.com>
" Version:     0.2
" Description: Opening a new line from a comment may insert an unwanted
" comment; the same is true for lists in markdown files.
" (re)pressing Enter will clear the line for you. This works if in
" insert mode and pressing Enter as well when using o or O in normal mode
" License:     Vim License (see :help license)
" Location:    plugin/double-tab.vim
" Website:     https://github.com/hneutr/double-tap
"
" See double-tap.txt for help. This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help doubletap.txt
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:doubletap_version = '0.2'

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" We need version 7 for <expr> mappings
" as well as the user wanting nocompatible
if exists("g:loaded_doubletap")
          \ || !has("comments")
          \ || v:version < 700
          \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_doubletap = 1
" }}}

" This patterns finds the wanted item in 'comments'
let s:pattern = '\([b,]\|^\):\zs\([^,]\+\)' 
                                         
" dict to hold the starters using the current filetype as key
let s:starters = {} 

" clears the line if the line is an empty comment or bullet-list item;
" otherwise, returns a normal <cr>
function! s:Detect_empty_comment_or_list()
  " Do nothing if no filetype set
  if empty(&ft)
    return "\<CR>"
  endif

  " if the filetype is markdown, set the starter as '-'
  if &ft == 'markdown'
    let s:starters[&ft] = '-'
  endif

  " record the comment starter
  if !has_key(s:starters, &ft)
    let s:starters[&ft] = matchstr(&comments, s:pattern)
  endif

  let line = getline('.')
  if s:starters[&ft] != '' && line =~ '^\s*\V'. s:starters[&ft] . '\m\s*$'
    return "\<C-U>"
  else
    return "\<CR>"
  endif
endfunction

if !hasmapto('<Plug>DoubletapDetect')
  silent! imap <unique> <CR> <Plug>DoubletapDetect
endif

inoremap <expr> <Plug>DoubletapDetect <SID>Detect_empty_comment_or_list()

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo
" }}}

" vim: set sw=2 sts=2 et fdm=marker:
