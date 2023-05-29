" Vim syntax support file
" Maintainer: Olivier Favre <of.olivier.favre@gmail.com>
" Last Change: 2023 May 29

" Transform a file into ANSI color codes, using the current syntax highlighting.

" This file uses line continuations
let s:cpo_sav = &cpo
let s:ls  = &ls
set cpo-=C

let s:end=line('$')

let s:settings = toansicolorcodes#GetUserSettings()

if exists('g:ansicolorcodes_truecolors') && g:ansicolorcodes_truecolors != '0'

  " Load GVim related configuration files
  " This was not done automatically because we need to run `vim`, not `gvim`

  " Load system-wide gvimrc
  runtime gvimrc
  " Load user-wide gvimrc
  if filereadable(expand('~/.gvimrc'))
    source ~/.gvimrc
  endif

  if !exists('v:colornames')
    " Load colorname to RGB translation table
    runtime syntax/2ansicolorcodes_colors.vim
  endif

  let s:whatterm = 'gui'

  " Hard-set Konsole 24 bits color codes
  let s:fg_code = "\x1B[38;2;%p1%sm"
  let s:bg_code = "\x1B[48;2;%p1%sm"

else

  if &t_Co > 1
    let s:whatterm = 'cterm'
  else
    let s:whatterm = 'term'
  endif

  if &t_AF != ''
    let s:fg_code = &t_AF
  else
    let s:fg_code = &t_Sf
  endif

  if &t_AB != ''
    let s:bg_code = &t_AB
  else
    let s:bg_code = &t_Sb
  endif

endif

let s:normal_id = synIDtrans(hlID('normal'))
let s:normal_fg = synIDattr(s:normal_id, 'fg#', s:whatterm)
let s:normal_bg = synIDattr(s:normal_id, 'bg#', s:whatterm)
let s:normal_fg_bold = synIDattr(s:normal_id, 'bold', s:whatterm)
" store last highlight attribute
let s:last_fg = -1
let s:last_bg = -1
let s:last_bold = 0
let s:last_inverse = 0
let s:last_standout = 0
let s:last_undercurl = 0
let s:last_italic = 0
let s:last_underline = 0
" memoization
let s:term_color_cache = {}

" set termcap
"     t_Co=8          : number of colors
"     t_AB=\e[4%p1%dm : ANSI background
"     t_AF=\e[3%p1%dm : ANSI foreground
"     t_mb=\e[5m      : blink
"     t_md=\e[1m      : bold
"     t_me=\e[m       : normal (no invert, no blink, no bold, default color, also no underline)
"     t_mr=\e[7m      : invert
"     t_op=\e[39;49m  : reset foreground and background
"     t_se=\e[27m     : standout end
"     t_so=\e[7m      : standout mode (sometimes invert)
"     t_ue=\e[m       : underline end
"     t_us=\e[4m      : underline mode
"     t_Ce=(N/A)      : undercurl end (gui mode only?)
"     t_Cs=(N/A)      : undercurl mode (gui mode only?)
"     t_ZH=\e[6m      : italic mode
"     t_ZR=\e[m       : italic end
"     t_Sb=\e[4%?%p1%{1}%=%t4%e%p1%{3}%=%t6%e%p1%{4}%=%t1%e%p1%{6}%=%t3%e%p1%d%;m
"                     : background
"     t_Sf=\e[3%?%p1%{1}%=%t4%e%p1%{3}%=%t6%e%p1%{4}%=%t1%e%p1%{6}%=%t3%e%p1%d%;m
"                     : foreground
" If t_Co is non zero:
"   Use t_AB and t_AF if available, t_Sb and t_Sf otherwise.
"   Use t_me to reset

" See term.c:void term_color(uchar*,int)
function! s:term_color(code, color)
  let code = a:code
  let color = a:color
  " Already memoized?
  let cache_key = color."#".code
  if has_key(s:term_color_cache, cache_key)
    return s:term_color_cache[cache_key]
  endif
  if color >= 8 && &t_Co >= 16
    let i = 0
    if code[0] == "\x9B"
      let i = 1
    elseif (code[0] == "\e" || code[0] == "\033" || code[0] == "\x27") && code[1] == '['
      let i = 2
    endif
    if i != 0 && code[i] != "\0"
          \ && (code[i] == '3' || code[i] == '4')
          \ && (code[(i+1):(i+1+6)] == '%p1%dm' || code[(i+1):(i+1+3)] == '%dm')
      if color >= 16
        let code = code[0 : (i)] . '8;5;' . code[(i+1) : ]
      else
        if code[i] == 3 "fg
          let code = code[0 : (i-1)] . '9' . code[(i+1) : ]
        else
          let code = code[0 : (i-1)] . '10' . code[(i+1) : ]
        endif
        let color = color - 8
      endif
    endif
  endif
  let rtn = s:tgoto(code, color)
  " Memoize result
  let s:term_color_cache[cache_key] = rtn
  return rtn
endfun
" See termlib.c:char* tgoto(char*,int,int)
" See man terminfo(5)#Parameterized-Strings
function! s:tgoto(code, color)
  let acolor = a:color   " as a variable, because it could be modified
  let stack = []         " value stack
  let e = strlen(a:code) " end offset of a:code
  let i = 0              " current offset inside a:code
  let ifmatched = 0      " whether a %t (then) matched
  let seekto = ''        " request to seek to a particular string sequence
  let code = ''          " string output
  while i < e
    let c = a:code[i]
    if c == '%' && i + 1 < e
      let i = i + 1
      let c = a:code[i]
      if c == '%'
        let code = code . '%'
      elseif c == 'p' && i + 1 < e && a:code[i+1] == '1' " push parameter 1 onto the stack
        " Only %p1 is defined, it is the color
        let i = i + 1
        let stack += [acolor]
      elseif c == 'd' " format number (simplified)
        let code = code . printf('%d', remove(stack, -1))
      elseif c == 's' " format string (simplified)
        let code = code . printf('%s', remove(stack, -1))
      elseif c == "'" && i + 2 < e && a:code[i+2] == "'" " push a character onto the stack
        let i = i + 2
        let stack += [a:code[i-1]]
      elseif c == '{' && i + 2 < e && a:code[i+2] == '}' " push a 1-digit number onto the stack
        let i = i + 2
        let stack += [a:code[i-1]]
      elseif c == '{' && i + 3 < e && a:code[i+3] == '}' " push a 2-digit number onto the stack
        let i = i + 3
        let stack += [a:code[i-2:i-1]]
      elseif c == '{' && i + 4 < e && a:code[i+4] == '}' " push a 3-digit number onto the stack (no need for more apparently)
        let i = i + 4
        let stack += [a:code[i-3:i-1]]
      elseif c == 'l' " replace topmost value by its length
        let stack += [strlen(remove(stack, -1))]
      elseif c == '+' " add the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a + b]
      elseif c == '-' " subtract the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a - b]
      elseif c == '*' " multiply the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a * b]
      elseif c == '/' " divide the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a / b]
      elseif c == 'm' " calculate modulus of the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a % b]
      elseif c == '&' || c == '|' || c == '^' || c == '!' || c == '~'
        " %& %| %^ %! %~ bitwise operations AND OR XOR NOT are not supported by vim
      elseif c == '<' " less-than comparison of the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a < b]
      elseif c == '=' " equality comparison of the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a == b]
      elseif c == '>' " greater-than comparison of the two topmost values
        let b = remove(stack, -1) + 0
        let a = remove(stack, -1) + 0
        let stack += [a > b]
      elseif c == 'i' " increment %p1
        let acolor = acolor + 1
      elseif c == '?' " if start
        " Ignore if nesting for simplicity
      elseif c == 't' " then
        if ifmatched == 1 " (should not happen)
          let seekto = '%;'
        elseif remove(stack, -1) == 0 " test topmost value
          let seekto = '%e' " jump to next else
        else
          let ifmatched = 1 " note we are inside an if clause body to permit jumping to if end afterwards
        endif
      elseif c == 'e' " else
        if ifmatched == 1 " the previous then matched, jump to if end
          let seekto = '%;'
        endif
      elseif c == ';' " if end
        let ifmatched = 0
      else " unknown escape
        let code = code . '%' . c
      endif
    else " regular character
      let code = code . c
    endif
    let i = i + 1
    " Eventual seek
    if seekto != ''
      let pos = stridx(a:code, seekto, i)
      if pos == -1 " rescue string not found by ignoring seek
        let pos = i
      endif
      if seekto != '%;'
        " Seeks are used inside ifs, don't permit crossing the if end
        let ifend = stridx(a:code, '%;', i)
        if ifend < pos " cap to if end if sought string is further (no final %e before %;)
          let pos = ifend
        endif
      endif
      let i = pos
      let seekto = ''
    endif
  endwhile

  return code
endfun
function! s:color_is_set(color)
  return a:color != '' && a:color >= 0
endfun
function! s:translate_color(color)
  if s:color_is_set(a:color)
    let l:color = a:color
    if l:color[0] !~ '^\v[#0-9]'
      if exists('v:colornames')
        let l:color = v:colornames[tolower(l:color)]
      else
        let l:color = g:ansicolorcodes_colors[tolower(l:color)]
      endif
    endif
    if l:color[0] == '#'
      let l:r = ('0x' . l:color[1:2]) + 0
      let l:g = ('0x' . l:color[3:4]) + 0
      let l:b = ('0x' . l:color[5:6]) + 0
      let l:color = l:r . ';' . l:g . ';' . l:b
    endif
  endif
  return l:color
endfun
if s:whatterm == 'gui'
  function! s:term_fg_color(color)
    if !s:color_is_set(a:color)
      return ''
    else
      return s:term_color(s:fg_code, s:translate_color(a:color))
    endif
  endfun
  " See term.c:void term_bg_color(int)
  function! s:term_bg_color(color)
    if !s:color_is_set(a:color)
      return ''
    else
      return s:term_color(s:bg_code, s:translate_color(a:color))
    endif
  endfun
else
  " See term.c:void term_fg_color(int)
  function! s:term_fg_color(color)
    if !s:color_is_set(a:color)
      return ''
    else
      return s:term_color(s:fg_code, a:color)
    endif
  endfun
  " See term.c:void term_bg_color(int)
  function! s:term_bg_color(color)
    if !s:color_is_set(a:color)
      return ''
    else
      return s:term_color(s:bg_code, a:color)
    endif
  endfun
endif
" See screen.c:void screen_start_highlight(int)
function! s:screen_start_highlight(id)
  let rtn = ''
  if &t_Co > 1 && s:normal_fg_bold && s:color_is_set(synIDattr(a:id, 'fg#', s:whatterm))
    let rtn = rtn . &t_me
  endif
  if exists('&t_md') && synIDattr(a:id, 'bold', s:whatterm)
    let rtn = rtn . &t_md
  endif
  if exists('&t_so') && synIDattr(a:id, 'standout', s:whatterm)
    let rtn = rtn . &t_so
  endif
  if exists('&t_us') && (synIDattr(a:id, 'underline', s:whatterm) || synIDattr(a:id, 'undercurl', s:whatterm))
    let rtn = rtn . &t_us
  endif
  if exists('&t_ZH') && synIDattr(a:id, 'italic', s:whatterm)
    let rtn = rtn . &t_ZH
  endif
  if exists('&t_mr') && synIDattr(a:id, 'inverse', s:whatterm)
    let rtn = rtn . &t_mr
  endif
  if &t_Co > 1
    if s:last_fg != synIDattr(a:id, 'fg#', s:whatterm) || s:last_bg != synIDattr(a:id, 'bg#', s:whatterm)
      if (s:color_is_set(s:last_fg) && !s:color_is_set(synIDattr(a:id, 'fg#', s:whatterm))) || (s:color_is_set(s:last_bg) && !s:color_is_set(synIDattr(a:id, 'bg#', s:whatterm)))
        let rtn = rtn . &t_op
      endif
      let s:last_fg = synIDattr(a:id, 'fg#', s:whatterm)
      let s:last_bg = synIDattr(a:id, 'bg#', s:whatterm)
      let rtn = rtn . s:term_fg_color(synIDattr(a:id, 'fg#', s:whatterm))
            \ . s:term_bg_color(synIDattr(a:id, 'bg#', s:whatterm))
    endif
  else
    " The following cannot be implemented due to lack of Vim script getters
    "let start = synIDattr(s:last_id, 'start', s:whatterm)
    "if start
    "  let rtn = rtn . start
    "endif
  endif
  let s:last_id = a:id
  let s:last_bold = synIDattr(a:id, 'bold', s:whatterm)
  let s:last_standout = synIDattr(a:id, 'standout', s:whatterm)
  let s:last_undercurl = synIDattr(a:id, 'undercurl', s:whatterm)
  let s:last_underline = synIDattr(a:id, 'underline', s:whatterm)
  let s:last_italic = synIDattr(a:id, 'italic', s:whatterm)
  let s:last_inverse = synIDattr(a:id, 'inverse', s:whatterm)
  let s:last_fg = synIDattr(a:id, 'fg#', s:whatterm)
  let s:last_bg = synIDattr(a:id, 'bg#', s:whatterm)
  return rtn
endfun
" See screen.c:void screen_stop_highlight()
function! s:screen_stop_highlight()
  let rtn = ''
  let me = 0
  if &t_Co > 1
    if s:color_is_set(s:last_fg) || s:color_is_set(s:last_bg)
      let me = 1 " assume &t_me restores the original colors
    else
      " The following cannot be implemented due to lack of Vim script getters
      "let stop = synIDattr(s:last_id, 'stop', s:whatterm)
      "if stop
      "  if stop == &t_me | let me = 1
      "  else | let rtn = rtn . stop | endif
      "endif
    endif
  endif
  if s:last_standout
    if &t_se == &t_me | let me = 1
    else | let rtn = rtn . &t_se | endif
  endif
  if s:last_underline || s:last_undercurl
    if &t_ue == &t_me | let me = 1
    else | let rtn = rtn . &t_ue | endif
  endif
  if s:last_italic
    if &t_ZR == &t_me | let me = 1
    else | let rtn = rtn . &t_ZR | endif
  endif
  if me == 1 || s:last_bold || s:last_inverse
    let rtn = rtn . &t_me
  endif
  if &t_Co > 1
    if s:color_is_set(s:normal_fg) | let rtn = rtn . s:term_fg_color(s:normal_fg) | endif
    if s:color_is_set(s:normal_bg) | let rtn = rtn . s:term_bg_color(s:normal_bg) | endif
    if s:normal_fg_bold | let rtn = rtn . &t_md | endif
  endif
  let s:last_id = -1
  let s:last_bold = 0
  let s:last_standout = 0
  let s:last_undercurl = 0
  let s:last_underline = 0
  let s:last_italic = 0
  let s:last_inverse = 0
  let s:last_fg = -1
  let s:last_bg = -1
  return rtn
endfun
" See screen.c:void reset_cterm_colors()
function! s:reset_cterm_colors()
  let rtn = ''
  if &t_Co > 1
    if s:color_is_set(s:normal_fg) || s:color_is_set(s:normal_bg)
      let rtn = rtn . &t_op
    endif
    if s:normal_fg_bold
      let rtn = rtn . &t_me
    endif
  endif
  let s:last_id = -1
  let s:last_bold = 0
  let s:last_standout = 0
  let s:last_undercurl = 0
  let s:last_underline = 0
  let s:last_italic = 0
  let s:last_inverse = 0
  let s:last_fg = -1
  let s:last_bg = -1
  return rtn
endfun

function! s:Format(text, name)
  let text = strtrans(a:text)
  let s:id = synIDtrans(hlID(a:name))
  return s:screen_start_highlight(s:id) . text . s:screen_stop_highlight()
endfun



" Set some options to make it work faster.
" Don't report changes for :substitute, there will be many of them.
" Don't change other windows; turn off scroll bind temporarily
let s:old_title = &title
let s:old_icon = &icon
let s:old_et = &l:et
let s:old_bind = &l:scrollbind
let s:old_report = &report
let s:old_search = @/
let s:old_more = &more
set notitle noicon
setlocal et
set nomore
set report=1000000
setlocal noscrollbind

if exists(':ownsyntax') && exists('w:current_syntax')
  let s:current_syntax = w:current_syntax
elseif exists('b:current_syntax')
  let s:current_syntax = b:current_syntax
else
  let s:current_syntax = 'none'
endif

if s:current_syntax == ''
  let s:current_syntax = 'none'
endif

" Split window to create a buffer with the ANSI color coded file.
let s:orgbufnr = winbufnr(0)
let s:origwin_stl = &l:stl
if expand('%') == ''
  exec 'new Untitled.cat'
else
  exec 'new %.cat'
endif

" Resize the new window to very small in order to make it draw faster
let s:old_winheight = winheight(0)
let s:old_winfixheight = &l:winfixheight
if s:old_winheight > 2
  resize 1 " leave enough room to view one line at a time
  norm! G
  norm! zt
endif
setlocal winfixheight

let s:newwin_stl = &l:stl

" on the new window, set the least time-consuming fold method
let s:old_fdm = &foldmethod
let s:old_fen = &foldenable
setlocal foldmethod=manual
setlocal nofoldenable

let s:newwin = winnr()
let s:orgwin = bufwinnr(s:orgbufnr)

setlocal modifiable
%d
let s:old_paste = &paste
set paste
let s:old_magic = &magic
set magic

" set the fileencoding to match the charset we'll be using
let &l:fileencoding=s:settings.vim_encoding

exe s:orgwin . 'wincmd w'



" Now loop over all lines in the original text to convert to ANSI color codes.
" Use ansicolorcodes_start_line and ansicolorcodes_end_line if they are set.
if exists('g:ansicolorcodes_start_line')
  let s:lnum = ansicolorcodes_start_line
  if s:lnum < 1 || s:lnum > line('$')
    let s:lnum = 1
  endif
else
  let s:lnum = 1
endif
if exists('g:ansicolorcodes_end_line')
  let s:end = ansicolorcodes_end_line
  if s:end < s:lnum || s:end > line('$')
    let s:end = line('$')
  endif
else
  let s:end = line('$')
endif



if s:settings.number_lines
  let s:margin = max([3, strlen(s:end)]) + 1
else
  let s:margin = 0
endif

if has('folding') && !s:settings.ignore_folding
  let s:foldfillchar = &fillchars[matchend(&fillchars, 'fold:')]
  if s:foldfillchar == ''
    let s:foldfillchar = '-'
  endif
endif

if !s:settings.expand_tabs
  " If keeping tabs, add them to printable characters so we keep them when
  " formatting text (strtrans() doesn't replace printable chars)
  let s:old_isprint = &isprint
  setlocal isprint+=9
endif



let s:lines = []

while s:lnum <= s:end
  " Start the line with the line number.
  if s:settings.number_lines
    let s:numcol = repeat(' ', s:margin - 1 - strlen(s:lnum)) . s:lnum . ' '
  else
    let s:numcol = ''
  endif

  if s:color_is_set(s:normal_bg)
    let s:new = &t_ce " clear to end of line to apply the normal background color
  else
    let s:new = ''
  endif

  if has('folding') && !s:settings.ignore_folding && foldclosed(s:lnum) > -1
    "
    " This is the beginning of a folded block
    "
    let s:new = s:numcol . foldtextresult(s:lnum)
    " Go ahead and fill to the margin
    let s:new = s:new . repeat(s:foldfillchar, &columns - strlen(s:new))

    let s:new = s:Format(s:new, 'Folded')

    " Skip to the end of the fold
    let s:new_lnum = foldclosedend(s:lnum)

    let s:lnum = s:new_lnum

  else
    "
    " A line that is not folded, or doing dynamic folding.
    "
    let s:line = getline(s:lnum)
    let s:len = strlen(s:line)

    " Now continue with the unfolded line text
    if s:settings.number_lines
      let s:new = s:new . s:Format(s:numcol, 'LineNr')
    endif

    " initialize conceal info to act like not concealed, just in case
    let s:concealinfo = [0, '']

    " Loop over each character in the line
    let s:col = 1

    while s:col <= s:len
      let s:startcol = s:col " The start column for processing text
      if !s:settings.ignore_conceal && has('conceal')
        let s:concealinfo = synconcealed(s:lnum, s:col)
      endif
      if !s:settings.ignore_conceal && s:concealinfo[0]
        let s:col = s:col + 1
        " Speed loop (it's small - that's the trick)
        " Go along till we find a change in the match sequence number (ending
        " the specific concealed region) or until there are no more concealed
        " characters.
        while s:col <= s:len && s:concealinfo == synconcealed(s:lnum, s:col) | let s:col = s:col + 1 | endwhile
      else
        let s:id = synID(s:lnum, s:col, 1)
        let s:col = s:col + 1
        " Speed loop (it's small - that's the trick)
        " Go along till we find a change in synID
        while s:col <= s:len && s:id == synID(s:lnum, s:col, 1) | let s:col = s:col + 1 | endwhile
      endif

      if s:settings.ignore_conceal || !s:concealinfo[0]
        " Expand tabs if needed
        let s:expandedtab = strpart(s:line, s:startcol - 1, s:col - s:startcol)
        if s:settings.expand_tabs
          let s:offset = 0
          let s:idx = stridx(s:expandedtab, "\t")
          while s:idx >= 0
            if has('multi_byte_encoding')
              if s:startcol + s:idx == 1
                let s:i = &ts
              else
                if s:idx == 0
                  let s:prevc = matchstr(s:line, '.\%' . (s:startcol + s:idx + s:offset) . 'c')
                else
                  let s:prevc = matchstr(s:expandedtab, '.\%' . (s:idx + 1) . 'c')
                endif
                let s:vcol = virtcol([s:lnum, s:startcol + s:idx + s:offset - len(s:prevc)])
                let s:i = &ts - (s:vcol % &ts)
              endif
              let s:offset -= s:i - 1
            else
              let s:i = &ts - ((s:idx + s:startcol - 1) % &ts)
            endif
            let s:expandedtab = substitute(s:expandedtab, '\t', repeat(' ', s:i), '')
            let s:idx = stridx(s:expandedtab, "\t")
          endwhile
        end

        " get the highlight group name to use
        let s:id = synIDtrans(s:id)
        let s:id_name = synIDattr(s:id, 'name', s:whatterm)
      else
        " use Conceal highlighting for concealed text
        let s:id_name = 'Conceal'
        let s:expandedtab = s:concealinfo[1]
      endif

      " Output the text with the same synID, with class set to {s:id_name},
      " unless it has been concealed completely.
      if strlen(s:expandedtab) > 0
        let s:new = s:new . s:Format(s:expandedtab,  s:id_name)
      endif
    endwhile
  endif

  call extend(s:lines, split(s:new, '\n', 1))
  let s:lnum = s:lnum + 1
endwhile

let s:lines[-1] = s:lines[-1] . s:reset_cterm_colors()
let s:lines[0] = s:reset_cterm_colors() . s:screen_stop_highlight() . s:lines[0]

exe s:newwin . 'wincmd w'
call setline(1, s:lines)
unlet s:lines

" Restore old settings (new window first)
let &l:foldenable = s:old_fen
let &l:foldmethod = s:old_fdm
let &report = s:old_report
let &title = s:old_title
let &icon = s:old_icon
let &paste = s:old_paste
let &magic = s:old_magic
let @/ = s:old_search
let &more = s:old_more

" switch to original window to restore those settings
exe s:orgwin . "wincmd w"

if !s:settings.expand_tabs
  let &l:isprint = s:old_isprint
endif
let &l:stl = s:origwin_stl
let &l:et = s:old_et
let &l:scrollbind = s:old_bind

" and back to the new window again to end there
exe s:newwin . "wincmd w"

let &l:stl = s:newwin_stl
exec 'resize' s:old_winheight
let &l:winfixheight = s:old_winfixheight

let &ls=s:ls

" Save a little bit of memory (worth doing?)
unlet s:old_et s:old_paste s:old_icon s:old_report s:old_title s:old_search
unlet s:old_magic s:old_more s:old_fdm s:old_fen s:old_winheight
unlet! s:old_isprint
unlet s:whatterm s:lnum s:end s:margin s:old_winfixheight
unlet! s:col s:id s:len s:line s:new s:expandedtab s:concealinfo
unlet! s:orgwin s:newwin s:orgbufnr s:idx s:i s:offset s:ls s:origwin_stl
unlet! s:newwin_stl s:current_syntax
if !v:profiling
  delfunc s:Format
  delfunc s:screen_start_highlight
  delfunc s:screen_stop_highlight
  delfunc s:term_fg_color
  delfunc s:term_bg_color
  delfunc s:term_color
  delfunc s:tgoto
endif

unlet! s:new_lnum s:numcol s:settings

let &cpo = s:cpo_sav
unlet! s:cpo_sav

unlet! s:bg_code s:cpo_sav s:fg_code s:id_name s:lines s:old_bind s:prevc s:startcol s:vcol
unlet! s:normal_id s:normal_fg s:normal_bg s:normal_fg_bold s:last_fg s:last_bg s:last_bold s:last_inverse s:last_standout s:last_undercurl s:last_italic s:last_underline
" Forget memoization to avoid leaking too much memory in adverse situations
unlet! s:term_color_cache

" vim: ts=8 sw=2 sts=2 et
