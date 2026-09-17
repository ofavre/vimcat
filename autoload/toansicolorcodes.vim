" Vim autoload file for the toansicolorcodes plugin.
" Maintainer: Olivier Favre <of.olivier.favre@gmail.com>
" Last Change: 2012 Aug 22

" this file uses line continuations
let s:cpo_sav = &cpo
set cpo-=C

" Automatically find charsets from all encodings supported natively by Vim. With
" the 8bit- and 2byte- prefixes, Vim can actually support more encodings than
" this. Let the user specify these however since they won't be supported on
" every system.
"
" Note, not all of Vim's supported encodings have a charset to use.
"
" Names in this list are from:
"   http://www.iana.org/assignments/character-sets
" g:toansicolorcodes#encoding_to_charset: {{{
let g:toansicolorcodes#encoding_to_charset = {
      \ 'latin1' : 'ISO-8859-1',
      \ 'iso-8859-2' : 'ISO-8859-2',
      \ 'iso-8859-3' : 'ISO-8859-3',
      \ 'iso-8859-4' : 'ISO-8859-4',
      \ 'iso-8859-5' : 'ISO-8859-5',
      \ 'iso-8859-6' : 'ISO-8859-6',
      \ 'iso-8859-7' : 'ISO-8859-7',
      \ 'iso-8859-8' : 'ISO-8859-8',
      \ 'iso-8859-9' : 'ISO-8859-9',
      \ 'iso-8859-10' : '',
      \ 'iso-8859-13' : 'ISO-8859-13',
      \ 'iso-8859-14' : '',
      \ 'iso-8859-15' : 'ISO-8859-15',
      \ 'koi8-r' : 'KOI8-R',
      \ 'koi8-u' : 'KOI8-U',
      \ 'macroman' : 'macintosh',
      \ 'cp437' : '',
      \ 'cp775' : '',
      \ 'cp850' : '',
      \ 'cp852' : '',
      \ 'cp855' : '',
      \ 'cp857' : '',
      \ 'cp860' : '',
      \ 'cp861' : '',
      \ 'cp862' : '',
      \ 'cp863' : '',
      \ 'cp865' : '',
      \ 'cp866' : 'IBM866',
      \ 'cp869' : '',
      \ 'cp874' : '',
      \ 'cp1250' : 'windows-1250',
      \ 'cp1251' : 'windows-1251',
      \ 'cp1253' : 'windows-1253',
      \ 'cp1254' : 'windows-1254',
      \ 'cp1255' : 'windows-1255',
      \ 'cp1256' : 'windows-1256',
      \ 'cp1257' : 'windows-1257',
      \ 'cp1258' : 'windows-1258',
      \ 'euc-jp' : 'EUC-JP',
      \ 'sjis' : 'Shift_JIS',
      \ 'cp932' : 'Shift_JIS',
      \ 'cp949' : '',
      \ 'euc-kr' : 'EUC-KR',
      \ 'cp936' : 'GBK',
      \ 'euc-cn' : 'GB2312',
      \ 'big5' : 'Big5',
      \ 'cp950' : 'Big5',
      \ 'utf-8' : 'UTF-8',
      \ 'ucs-2' : 'UTF-8',
      \ 'ucs-2le' : 'UTF-8',
      \ 'utf-16' : 'UTF-8',
      \ 'utf-16le' : 'UTF-8',
      \ 'ucs-4' : 'UTF-8',
      \ 'ucs-4le' : 'UTF-8',
      \ }
lockvar g:toansicolorcodes#encoding_to_charset
" Notes:
"   1. All UCS/UTF are converted to UTF-8 because it is much better supported
"   2. Any blank spaces are there because Vim supports it but at least one major
"      web browser does not according to http://wiki.whatwg.org/wiki/Web_Encodings.
" }}}

" Only automatically find encodings supported natively by Vim, let the user
" specify the encoding if it's not natively supported. This function is only
" used when the user specifies the charset, they better know what they are
" doing!
"
" Names in this list are from:
"   http://www.iana.org/assignments/character-sets
" g:toansicolorcodes#charset_to_encoding: {{{
let g:toansicolorcodes#charset_to_encoding = {
      \ 'iso_8859-1:1987' : 'latin1',
      \ 'iso-ir-100' : 'latin1',
      \ 'iso_8859-1' : 'latin1',
      \ 'iso-8859-1' : 'latin1',
      \ 'latin1' : 'latin1',
      \ 'l1' : 'latin1',
      \ 'ibm819' : 'latin1',
      \ 'cp819' : 'latin1',
      \ 'csisolatin1' : 'latin1',
      \ 'iso_8859-2:1987' : 'iso-8859-2',
      \ 'iso-ir-101' : 'iso-8859-2',
      \ 'iso_8859-2' : 'iso-8859-2',
      \ 'iso-8859-2' : 'iso-8859-2',
      \ 'latin2' : 'iso-8859-2',
      \ 'l2' : 'iso-8859-2',
      \ 'csisolatin2' : 'iso-8859-2',
      \ 'iso_8859-3:1988' : 'iso-8859-3',
      \ 'iso-ir-109' : 'iso-8859-3',
      \ 'iso_8859-3' : 'iso-8859-3',
      \ 'iso-8859-3' : 'iso-8859-3',
      \ 'latin3' : 'iso-8859-3',
      \ 'l3' : 'iso-8859-3',
      \ 'csisolatin3' : 'iso-8859-3',
      \ 'iso_8859-4:1988' : 'iso-8859-4',
      \ 'iso-ir-110' : 'iso-8859-4',
      \ 'iso_8859-4' : 'iso-8859-4',
      \ 'iso-8859-4' : 'iso-8859-4',
      \ 'latin4' : 'iso-8859-4',
      \ 'l4' : 'iso-8859-4',
      \ 'csisolatin4' : 'iso-8859-4',
      \ 'iso_8859-5:1988' : 'iso-8859-5',
      \ 'iso-ir-144' : 'iso-8859-5',
      \ 'iso_8859-5' : 'iso-8859-5',
      \ 'iso-8859-5' : 'iso-8859-5',
      \ 'cyrillic' : 'iso-8859-5',
      \ 'csisolatincyrillic' : 'iso-8859-5',
      \ 'iso_8859-6:1987' : 'iso-8859-6',
      \ 'iso-ir-127' : 'iso-8859-6',
      \ 'iso_8859-6' : 'iso-8859-6',
      \ 'iso-8859-6' : 'iso-8859-6',
      \ 'ecma-114' : 'iso-8859-6',
      \ 'asmo-708' : 'iso-8859-6',
      \ 'arabic' : 'iso-8859-6',
      \ 'csisolatinarabic' : 'iso-8859-6',
      \ 'iso_8859-7:1987' : 'iso-8859-7',
      \ 'iso-ir-126' : 'iso-8859-7',
      \ 'iso_8859-7' : 'iso-8859-7',
      \ 'iso-8859-7' : 'iso-8859-7',
      \ 'elot_928' : 'iso-8859-7',
      \ 'ecma-118' : 'iso-8859-7',
      \ 'greek' : 'iso-8859-7',
      \ 'greek8' : 'iso-8859-7',
      \ 'csisolatingreek' : 'iso-8859-7',
      \ 'iso_8859-8:1988' : 'iso-8859-8',
      \ 'iso-ir-138' : 'iso-8859-8',
      \ 'iso_8859-8' : 'iso-8859-8',
      \ 'iso-8859-8' : 'iso-8859-8',
      \ 'hebrew' : 'iso-8859-8',
      \ 'csisolatinhebrew' : 'iso-8859-8',
      \ 'iso_8859-9:1989' : 'iso-8859-9',
      \ 'iso-ir-148' : 'iso-8859-9',
      \ 'iso_8859-9' : 'iso-8859-9',
      \ 'iso-8859-9' : 'iso-8859-9',
      \ 'latin5' : 'iso-8859-9',
      \ 'l5' : 'iso-8859-9',
      \ 'csisolatin5' : 'iso-8859-9',
      \ 'iso-8859-10' : 'iso-8859-10',
      \ 'iso-ir-157' : 'iso-8859-10',
      \ 'l6' : 'iso-8859-10',
      \ 'iso_8859-10:1992' : 'iso-8859-10',
      \ 'csisolatin6' : 'iso-8859-10',
      \ 'latin6' : 'iso-8859-10',
      \ 'iso-8859-13' : 'iso-8859-13',
      \ 'iso-8859-14' : 'iso-8859-14',
      \ 'iso-ir-199' : 'iso-8859-14',
      \ 'iso_8859-14:1998' : 'iso-8859-14',
      \ 'iso_8859-14' : 'iso-8859-14',
      \ 'latin8' : 'iso-8859-14',
      \ 'iso-celtic' : 'iso-8859-14',
      \ 'l8' : 'iso-8859-14',
      \ 'iso-8859-15' : 'iso-8859-15',
      \ 'iso_8859-15' : 'iso-8859-15',
      \ 'latin-9' : 'iso-8859-15',
      \ 'koi8-r' : 'koi8-r',
      \ 'cskoi8r' : 'koi8-r',
      \ 'koi8-u' : 'koi8-u',
      \ 'macintosh' : 'macroman',
      \ 'mac' : 'macroman',
      \ 'csmacintosh' : 'macroman',
      \ 'ibm437' : 'cp437',
      \ 'cp437' : 'cp437',
      \ '437' : 'cp437',
      \ 'cspc8codepage437' : 'cp437',
      \ 'ibm775' : 'cp775',
      \ 'cp775' : 'cp775',
      \ 'cspc775baltic' : 'cp775',
      \ 'ibm850' : 'cp850',
      \ 'cp850' : 'cp850',
      \ '850' : 'cp850',
      \ 'cspc850multilingual' : 'cp850',
      \ 'ibm852' : 'cp852',
      \ 'cp852' : 'cp852',
      \ '852' : 'cp852',
      \ 'cspcp852' : 'cp852',
      \ 'ibm855' : 'cp855',
      \ 'cp855' : 'cp855',
      \ '855' : 'cp855',
      \ 'csibm855' : 'cp855',
      \ 'ibm857' : 'cp857',
      \ 'cp857' : 'cp857',
      \ '857' : 'cp857',
      \ 'csibm857' : 'cp857',
      \ 'ibm860' : 'cp860',
      \ 'cp860' : 'cp860',
      \ '860' : 'cp860',
      \ 'csibm860' : 'cp860',
      \ 'ibm861' : 'cp861',
      \ 'cp861' : 'cp861',
      \ '861' : 'cp861',
      \ 'cp-is' : 'cp861',
      \ 'csibm861' : 'cp861',
      \ 'ibm862' : 'cp862',
      \ 'cp862' : 'cp862',
      \ '862' : 'cp862',
      \ 'cspc862latinhebrew' : 'cp862',
      \ 'ibm863' : 'cp863',
      \ 'cp863' : 'cp863',
      \ '863' : 'cp863',
      \ 'csibm863' : 'cp863',
      \ 'ibm865' : 'cp865',
      \ 'cp865' : 'cp865',
      \ '865' : 'cp865',
      \ 'csibm865' : 'cp865',
      \ 'ibm866' : 'cp866',
      \ 'cp866' : 'cp866',
      \ '866' : 'cp866',
      \ 'csibm866' : 'cp866',
      \ 'ibm869' : 'cp869',
      \ 'cp869' : 'cp869',
      \ '869' : 'cp869',
      \ 'cp-gr' : 'cp869',
      \ 'csibm869' : 'cp869',
      \ 'windows-1250' : 'cp1250',
      \ 'windows-1251' : 'cp1251',
      \ 'windows-1253' : 'cp1253',
      \ 'windows-1254' : 'cp1254',
      \ 'windows-1255' : 'cp1255',
      \ 'windows-1256' : 'cp1256',
      \ 'windows-1257' : 'cp1257',
      \ 'windows-1258' : 'cp1258',
      \ 'extended_unix_code_packed_format_for_japanese' : 'euc-jp',
      \ 'cseucpkdfmtjapanese' : 'euc-jp',
      \ 'euc-jp' : 'euc-jp',
      \ 'shift_jis' : 'sjis',
      \ 'ms_kanji' : 'sjis',
      \ 'sjis' : 'sjis',
      \ 'csshiftjis' : 'sjis',
      \ 'ibm-thai' : 'cp874',
      \ 'csibmthai' : 'cp874',
      \ 'ks_c_5601-1987' : 'cp949',
      \ 'iso-ir-149' : 'cp949',
      \ 'ks_c_5601-1989' : 'cp949',
      \ 'ksc_5601' : 'cp949',
      \ 'korean' : 'cp949',
      \ 'csksc56011987' : 'cp949',
      \ 'euc-kr' : 'euc-kr',
      \ 'cseuckr' : 'euc-kr',
      \ 'gbk' : 'cp936',
      \ 'cp936' : 'cp936',
      \ 'ms936' : 'cp936',
      \ 'windows-936' : 'cp936',
      \ 'gb_2312-80' : 'euc-cn',
      \ 'iso-ir-58' : 'euc-cn',
      \ 'chinese' : 'euc-cn',
      \ 'csiso58gb231280' : 'euc-cn',
      \ 'big5' : 'big5',
      \ 'csbig5' : 'big5',
      \ 'utf-8' : 'utf-8',
      \ 'iso-10646-ucs-2' : 'ucs-2',
      \ 'csunicode' : 'ucs-2',
      \ 'utf-16' : 'utf-16',
      \ 'utf-16be' : 'utf-16',
      \ 'utf-16le' : 'utf-16le',
      \ 'utf-32' : 'ucs-4',
      \ 'utf-32be' : 'ucs-4',
      \ 'utf-32le' : 'ucs-4le',
      \ 'iso-10646-ucs-4' : 'ucs-4',
      \ 'csucs4' : 'ucs-4'
      \ }
lockvar g:toansicolorcodes#charset_to_encoding
"}}}

func! toansicolorcodes#Convert2ANSIColorCodes(line1, line2) "{{{
  let s:settings = toansicolorcodes#GetUserSettings()

  if a:line2 >= a:line1 "{{{
    let g:ansicolorcodes_start_line = a:line1
    let g:ansicolorcodes_end_line = a:line2
  else
    let g:ansicolorcodes_start_line = a:line2
    let g:ansicolorcodes_end_line = a:line1
  endif
  runtime syntax/2ansicolorcodes.vim "}}}

  unlet g:ansicolorcodes_start_line
  unlet g:ansicolorcodes_end_line
  unlet s:settings
endfunc "}}}

" Gets a single user option and sets it in the passed-in Dict, or gives it the
" default value if the option doesn't actually exist.
func! toansicolorcodes#GetOption(settings, option, default) "{{{
  if exists('g:ansicolorcodes_'.a:option)
    let a:settings[a:option] = g:ansicolorcodes_{a:option}
  else
    let a:settings[a:option] = a:default
  endif
endfunc "}}}

" returns a Dict containing the values of all user options for 2ansicolorcodes, including
" default values for those not given an explicit value by the user. Discards the
" html_ prefix of the option for nicer looking code.
func! toansicolorcodes#GetUserSettings() "{{{
  if exists('s:settings')
    " just restore the known options if we've already retrieved them
    return s:settings
  else
    " otherwise figure out which options are set
    let user_settings = {}

    " get current option settings with appropriate defaults {{{
    call toansicolorcodes#GetOption(user_settings,    'no_progress', !has("statusline") )
    call toansicolorcodes#GetOption(user_settings,   'number_lines', &number )
    call toansicolorcodes#GetOption(user_settings, 'ignore_conceal', 0 )
    call toansicolorcodes#GetOption(user_settings, 'ignore_folding', 0 )
    call toansicolorcodes#GetOption(user_settings,   'whole_filler', 0 )
    " }}}
    
    " set up expand_tabs option after all the overrides so we know the
    " appropriate defaults {{{
    call toansicolorcodes#GetOption(user_settings,
          \ 'expand_tabs',
          \ &expandtab || &ts != 8 || user_settings.number_lines)
    " }}}

    if exists("g:ansicolorcodes_use_encoding") "{{{
      " user specified the desired MIME charset, figure out proper
      " 'fileencoding' from it or warn the user if we cannot
      let user_settings.encoding = g:ansicolorcodes_use_encoding
      let user_settings.vim_encoding = toansicolorcodes#EncodingFromCharset(g:ansicolorcodes_use_encoding)
      if user_settings.vim_encoding == ''
        echohl WarningMsg
        echomsg "TOansicolorcodes: file encoding for"
              \ g:ansicolorcodes_use_encoding
              \ "unknown, please set 'fileencoding'"
        echohl None
      endif
    else
      " Figure out proper MIME charset from 'fileencoding' if possible
      if &l:fileencoding != '' 
        " If the buffer is not a "normal" type, the 'fileencoding' value may not
        " be trusted; since the buffer should not be written the fileencoding is
        " not intended to be used.
        if &l:buftype=='' || &l:buftype==?'help'
          let user_settings.vim_encoding = &l:fileencoding
          call toansicolorcodes#CharsetFromEncoding(user_settings)
        else
          let user_settings.encoding = '' " trigger detection using &encoding
        endif
      endif

      " else from 'encoding' if possible
      if &l:fileencoding == '' || user_settings.encoding == ''
        let user_settings.vim_encoding = &encoding
        call toansicolorcodes#CharsetFromEncoding(user_settings)
      endif

      " else default to UTF-8 and warn user
      if user_settings.encoding == ''
        let user_settings.vim_encoding = 'utf-8'
        let user_settings.encoding = 'UTF-8'
        echohl WarningMsg
        echomsg "TOansicolorcodes: couldn't determine MIME charset, using UTF-8"
        echohl None
      endif
    endif "}}}

    " TODO: font

    return user_settings
  endif
endfunc "}}}

" get the proper HTML charset name from a Vim encoding option.
function! toansicolorcodes#CharsetFromEncoding(settings) "{{{
  let l:vim_encoding = a:settings.vim_encoding
  if exists('g:ansicolorcodes_charset_override') && has_key(g:ansicolorcodes_charset_override, l:vim_encoding)
    let a:settings.encoding = g:ansicolorcodes_charset_override[l:vim_encoding]
  else
    if l:vim_encoding =~ '^8bit\|^2byte'
      " 8bit- and 2byte- prefixes are to indicate encodings available on the
      " system that Vim will convert with iconv(), look up just the encoding name,
      " not Vim's prefix.
      let l:vim_encoding = substitute(l:vim_encoding, '^8bit-\|^2byte-', '', '')
    endif
    if has_key(g:toansicolorcodes#encoding_to_charset, l:vim_encoding)
      let a:settings.encoding = g:toansicolorcodes#encoding_to_charset[l:vim_encoding]
    else
      let a:settings.encoding = ""
    endif
  endif
  if a:settings.encoding != ""
    let l:vim_encoding = toansicolorcodes#EncodingFromCharset(a:settings.encoding)
    if l:vim_encoding != ""
      " if the Vim encoding to HTML encoding conversion is set up (by default or
      " by the user) to convert to a different encoding, we need to also change
      " the Vim encoding of the new buffer
      let a:settings.vim_encoding = l:vim_encoding
    endif
  endif
endfun "}}}

" Get the proper Vim encoding option setting from an HTML charset name.
function! toansicolorcodes#EncodingFromCharset(encoding) "{{{
  if exists('g:ansicolorcodes_encoding_override') && has_key(g:ansicolorcodes_encoding_override, a:encoding)
    return g:ansicolorcodes_encoding_override[a:encoding]
  elseif has_key(g:toansicolorcodes#charset_to_encoding, tolower(a:encoding))
    return g:toansicolorcodes#charset_to_encoding[tolower(a:encoding)]
  else
    return ""
  endif
endfun "}}}

let &cpo = s:cpo_sav
unlet s:cpo_sav

" Make sure any patches will probably use consistent indent
"   vim: ts=2 sw=2 sts=2 et fdm=marker
