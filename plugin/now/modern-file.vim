" Vim plugin file
" Maintainer:       Nikolai Weibull <now@bitwi.se>
" Latest Revision:  2006-07-26

if exists("loaded_plugin_now_modern_file")
  finish
endif
let loaded_plugin_now_modern_file = 1

let s:cpo_save = &cpo
set cpo&vim

runtime lib/now.vim
runtime lib/now/mbc.vim

augroup now-modern-file
  autocmd BufWinEnter  * silent call <SID>modern_file_on_enter()
augroup end

if !hasmapto('<Plug>modern_file_info')
  nmap <unique> <C-g> <Plug>modern_file_info
endif
nnoremap <unique> <script> <Plug>modern_file_info <SID>modern_file_info
nnoremap <SID>modern_file_info <Esc>:call <SID>modern_file_info(v:count)<CR>

command File call s:modern_file_info()

function s:modern_file_on_enter()
  if &previewwindow
    return
  endif
  call feedkeys("\<Plug>modern_file_info")
endfunction

function s:modern_file_info(...)
  let name_prefix = bufnr('%') . '. “'
  if &buftype == 'nofile'
    let name = bufname('%')
  else
    let name = substitute(expand('%:p'), $HOME, '~', '')
    let name = name != "" ? name : '[No Name]'
  endif
  let name_suffix = '”'
  " TODO: Default fileformat should be retrieved from &fileformat somehow.
  let info = filter([[&filetype, 'None'],
               \  [(&modified ? '+' : "") . (!&modifiable ? '-' : ""), 'NOWModernFileMod'],
               \  [&readonly ? 'RO' : "", 'NOWModernFileRO'],
               \  [&fileencoding, 'None'],
               \  [&fileformat != 'unix' ? &fileformat : "", 'None']],
               \ 'v:val[0] != ""')
  let info_len = 0
  for [str, _hlgroup] in info
    let info_len += g:NOW.MBC.width(str)
  endfor
  if info_len > 0
    let info_len += g:NOW.MBC.width(' []') + (len(info) - 1)
  endif
  let [line, nlines, vcol, col] = [line('.'), line('$'), virtcol('.'), col('.')]
  let extra_info = ' line ' . line . ' of ' . nlines .
                 \ ' (' . (100 * line / nlines) . '%); column ' . vcol
  if col != vcol
    let extra_info .= ' (byte index ' . col . ')'
  endif

  let room_for_name = &columns - g:NOW.MBC.width(name_prefix) -
                    \ g:NOW.MBC.width(name_suffix) - info_len -
                    \ g:NOW.MBC.width(extra_info) - 1 - 10 - 1
  let name_width = g:NOW.MBC.width(name)
  if name_width > room_for_name
    let name = '…' . g:NOW.MBC.part(name, name_width - room_for_name + 1)
  endif

  let ruler_saved = &ruler
  let showcmd_saved = &showcmd
  set noruler noshowcmd
  echon name_prefix
  echohl Directory | echon name | echohl None
  echon name_suffix
  if len(info) > 0
    echon ' ['
    let separator = ""
    for [str, hlgroup] in info
      echon separator
      execute 'echohl' hlgroup
      echon str
      echohl None
      let separator = ','
    endfor
    echon ']'
  endif
  echon extra_info
  let &showcmd = showcmd_saved
  let &ruler = ruler_saved
endfunction

let &cpo = s:cpo_save
