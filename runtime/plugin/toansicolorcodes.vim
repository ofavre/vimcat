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

" Make sure any patches will probably use consistent indent
"   vim: ts=2 sw=2 sts=2 et
