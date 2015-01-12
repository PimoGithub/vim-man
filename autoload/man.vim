let s:man_tag_depth = 0

let s:man_sect_arg = ''
let s:man_find_arg = '-w'
try
  if !has('win32') && $OSTYPE !~ 'cygwin\|linux' && system('uname -s') =~ 'SunOS' && system('uname -r') =~ '^5'
    let s:man_sect_arg = '-s'
    let s:man_find_arg = '-l'
  endif
catch /E145:/
  " Ignore the error in restricted mode
endtry

function! man#get_page(...)
  if a:0 == 1
    let sect = ''
    let page = a:1
  elseif a:0 >= 2
    let sect = a:1
    let page = a:2
  else
    return
  endif

  " To support:  nmap K :Man <cword>
  if page == '<cword>'
    let page = expand('<cword>')
  endif

  if sect != '' && !s:manpage_exists(sect, page)
    let sect = ''
  endif
  if !s:manpage_exists(sect, page)
    echohl ErrorMSG | echo "No manual entry for '".page."'." | echohl NONE
    return
  endif

  call s:update_man_tag_variables()
  call s:get_new_or_existing_man_window()
  call s:set_manpage_buffer_name(page, sect)
  call s:load_manpage_text(page, sect)
endfunction

function! man#get_page_from_cword(cnt)
  if a:cnt == 0
    " trying to determine manpage section from a word like this 'printf(3)'
    let old_isk = &iskeyword
    setlocal iskeyword+=(,)
    let str = expand('<cword>')
    let &l:iskeyword = old_isk
    let page = substitute(str, '(*\(\k\+\).*', '\1', '')
    let sect = substitute(str, '\(\k\+\)(\([^()]*\)).*', '\2', '')
    if sect !~# '^[0-9 ]\+$' || sect == page
      let sect = ''
    endif
  else
    let sect = a:cnt
    let page = expand('<cword>')
  endif
  call man#get_page(sect, page)
endfunction

function! man#pop_page()
  if s:man_tag_depth > 0
    let s:man_tag_depth = s:man_tag_depth - 1
    exec 'let s:man_tag_buf=s:man_tag_buf_'.s:man_tag_depth
    exec 'let s:man_tag_lin=s:man_tag_lin_'.s:man_tag_depth
    exec 'let s:man_tag_col=s:man_tag_col_'.s:man_tag_depth
    exec s:man_tag_buf.'b'
    exec s:man_tag_lin
    exec 'norm '.s:man_tag_col.'|'
    exec 'unlet s:man_tag_buf_'.s:man_tag_depth
    exec 'unlet s:man_tag_lin_'.s:man_tag_depth
    exec 'unlet s:man_tag_col_'.s:man_tag_depth
    unlet s:man_tag_buf s:man_tag_lin s:man_tag_col
  endif
endfunction

" helper functions {{{1

function! s:get_cmd_arg(sect, page)
  if a:sect == ''
    return a:page
  else
    return s:man_sect_arg.' '.a:sect.' '.a:page
  endif
endfunction

function! s:manpage_exists(sect, page)
  let where = system('/usr/bin/man '.s:man_find_arg.' '.s:get_cmd_arg(a:sect, a:page))
  if where !~# '^\s*/'
    " result does not look like a file path
    return 0
  else
    " found a manpage
    return 1
  endif
endfunction

function! s:remove_blank_lines_from_top_and_bottom()
  while getline(1) =~ '^\s*$'
    silent keepj norm! ggdd
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepj norm! Gdd
  endwhile
  silent keepj norm! gg
endfunction

function! s:set_manpage_buffer_name(page, section)
  if a:section
    silent exec 'edit '.a:page.'('.a:section.')\ manpage'
  else
    silent exec 'edit '.a:page.'\ manpage'
  endif
endfunction

function! s:load_manpage_text(page, section)
  setlocal modifiable
  silent keepj norm! 1GdG
  let $MANWIDTH = winwidth(0)
  silent exec 'r!/usr/bin/man '.s:get_cmd_arg(a:section, a:page).' | col -b'
  call s:remove_blank_lines_from_top_and_bottom()
  setlocal filetype=man
  setlocal nomodifiable
endfunction

function! s:get_new_or_existing_man_window()
  if &filetype != 'man'
    let thiswin = winnr()
    exec "norm! \<C-W>b"
    if winnr() > 1
      exec 'norm! '.thiswin."\<C-W>w"
      while 1
        if &filetype == 'man'
          break
        endif
        exec "norm! \<C-W>w"
        if thiswin == winnr()
          break
        endif
      endwhile
    endif
    if &filetype != 'man'
      new
    endif
  endif
endfunction

function! s:update_man_tag_variables()
  exec 'let s:man_tag_buf_'.s:man_tag_depth.' = '.bufnr('%')
  exec 'let s:man_tag_lin_'.s:man_tag_depth.' = '.line('.')
  exec 'let s:man_tag_col_'.s:man_tag_depth.' = '.col('.')
  let s:man_tag_depth = s:man_tag_depth + 1
endfunction

" }}}

" vim:set ft=vim et sw=2:
