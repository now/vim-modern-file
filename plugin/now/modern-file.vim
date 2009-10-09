if exists("loaded_plugin_now_modern_file")
  finish
endif
let loaded_plugin_now_modern_file = 1

let s:cpo_save = &cpo
set cpo&vim

augroup plugin-now-modern-file
  autocmd!
  autocmd BufWinEnter * silent call <SID>modern_file_on_enter()
augroup end

if !hasmapto('<Plug>modern_file_info')
  nmap <unique> <C-g> <Plug>modern_file_info
endif
nnoremap <unique> <script> <Plug>modern_file_info <SID>modern_file_info
nnoremap <silent> <SID>modern_file_info <Esc>:call <SID>modern_file_info()<CR>

command! File call s:modern_file_info()

function! s:modern_file_on_enter()
  if &previewwindow || mode() != 'n'
    return
  endif
  call feedkeys("\<Plug>modern_file_info")
endfunction

function! s:modern_file_info(...)
  let buffer_number = bufnr('%') . '. '
  let name = s:get_buffer_name()
  let suffix = s:path_relative_to_working_directory(name)
  let info = filter([[&filetype, 'None'],
               \  [(&modified ? '+' : "") . (!&modifiable ? '-' : ""), 'NOWModernFileMod'],
               \  [&readonly ? 'RO' : "", 'NOWModernFileRO'],
               \  [&fileencoding != 'utf-8' ? &fileencoding : "", 'None'],
               \  [&fileformat != 'unix' ? &fileformat : "", 'None']],
               \ 'v:val[0] != ""')
  let info_len = 0
  for [str, _hlgroup] in info
    let info_len += strlen(str)
  endfor
  if info_len > 0
    let info_len += strlen(' []') + (len(info) - 1)
  endif
  let [line, nlines, vcol, col] = [line('.'), line('$'), virtcol('.'), col('.')]
  let extra_info = ' line ' . line . ' of ' . nlines .
                 \ ' (' . (100 * line / nlines) . '%); column ' . vcol
  if col != vcol
    let extra_info .= ' (byte index ' . col . ')'
  endif

  let room_for_name = &columns - now#mbc#width(buffer_number) - info_len -
                    \ now#mbc#width(extra_info) - 1 - 10 - 1
  let name_width = now#mbc#width(name)
  if name_width > room_for_name
    let name = now#mbc#part(name, name_width - room_for_name + 1)
    if len(name) < len(suffix)
      let suffix = name
    endif
    let name = '…' . name
  endif

  let ruler_saved = &ruler
  let showcmd_saved = &showcmd
  set noruler noshowcmd
  echon buffer_number
  echohl NOWModernFileCommonPrefix
    echon strpart(name, 0, len(name) - len(suffix))
  echohl None
  echon suffix
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

function! s:get_buffer_name()
  if &buftype == 'nofile'
    return bufname('%')
  endif
  let name = s:simplify_path(expand('%:p'))
  return name != "" ? name : '[No Name]'
endfunction

function! s:simplify_path(path)
  if stridx(a:path, $HOME) != 0
    return a:path
  endif
  return '~' . strpart(a:path, len($HOME) - ($HOME[len($HOME) - 1] == '/' ? 1 : 0))
endfunction

function! s:path_relative_to_working_directory(path)
  let cwd = s:simplify_path(getcwd())
  if stridx(a:path, cwd) != 0
    return a:path
  endif
  let n = len(cwd)
  return strpart(a:path, n + (len(a:path) > n && a:path[n] == '/' ? 1 : 0))
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
