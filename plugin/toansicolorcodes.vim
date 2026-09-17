" Vim plugin for converting a syntax highlighted file to ANSI color codes.
" Maintainer: Olivier Favre <of.olivier.favre@gmail.com>
" Last Change: 2012 Aug 22
"
" The core of the code is in $VIMRUNTIME/autoload/toansicolorcodes.vim and
" $VIMRUNTIME/syntax/2ansicolorcodes.vim
"

if exists('g:loaded_2ansicolorcodes_plugin')
  finish
endif
let g:loaded_2ansicolorcodes_plugin = 'vim7.3_v10'

"
" Changelog:
"   7.3_v10 (this version): First version

" Define the :TOansicolorcodes command when:
" - 'compatible' is not set
" - this plugin was not already loaded
" - user commands are available.
if !&cp && !exists(":TOansicolorcodes") && has("user_commands")
  command -range=% TOansicolorcodes :call toansicolorcodes#Convert2ANSIColorCodes(<line1>, <line2>)
endif

let s:plugin_root = expand('<sfile>:p:h:h')

" Automatically install/symlink vimcat CLI binary into user's PATH if missing
function! s:VimcatInstall()
  if get(g:, 'vimcat_auto_install', 1) == 0
    return
  endif

  if executable('vimcat')
    return
  endif

  let l:src = s:plugin_root . '/vimcat'
  if !filereadable(l:src)
    return
  endif

  let l:candidates = [expand('~/.local/bin'), expand('~/bin'), expand('~/.bin')]
  let l:target_dir = ''
  let l:path_dirs = split($PATH, has('win32') ? ';' : ':')

  for l:cand in l:candidates
    for l:p in l:path_dirs
      if fnamemodify(l:cand, ':p') ==# fnamemodify(l:p, ':p')
        let l:target_dir = l:cand
        break
      endif
    endfor
    if !empty(l:target_dir)
      break
    endif
  endfor

  if empty(l:target_dir)
    for l:cand in l:candidates
      if isdirectory(l:cand)
        let l:target_dir = l:cand
        break
      endif
    endfor
  endif

  if empty(l:target_dir)
    let l:target_dir = expand('~/.local/bin')
  endif

  if !isdirectory(l:target_dir)
    call mkdir(l:target_dir, 'p')
  endif

  let l:dest = l:target_dir . '/vimcat'

  if has('win32')
    call system('copy /Y ' . shellescape(l:src) . ' ' . shellescape(l:dest))
  else
    call system('ln -sf ' . shellescape(l:src) . ' ' . shellescape(l:dest))
  endif

  if executable(l:dest) || executable('vimcat')
    echomsg 'vimcat: Automatically installed executable to ' . l:dest
  endif
endfunction

if !&cp && has("user_commands")
  command! -bang VimcatInstall call s:VimcatInstall()
  call s:VimcatInstall()
endif

" Make sure any patches will probably use consistent indent
"   vim: ts=2 sw=2 sts=2 et


