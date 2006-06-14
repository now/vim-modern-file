" Vim plugin file
" Maintainer:       Nikolai Weibull <now@bitwi.se>
" Latest Revision:  2006-06-14

if exists("loaded_plugin_now_modern_file")
  finish
endif
let loaded_plugin_now_modern_file = 1

let s:cpo_save = &cpo
set cpo&vim

nnoremap <C-g> :call <SID>modern_file_info()<CR>
command File call s:modern_file_info()

function s:modern_file_info()
  let name = substitute(expand('%:p'), $HOME, '~', '')
  let name = name != '' ? name : '[No Name]'
  echon bufnr('%') '. “' | echohl Directory | echon name | echohl None | echon '”'
  " TODO: default fileformat should be retrieved from &fileformat somehow.
  let info = filter([[&filetype, 'None'],
               \  [(&modified ? '+' : "") . (!&modifiable ? '-' : ""), 'NOWModernFileMod'],
               \  [&readonly ? 'RO' : "", 'NOWModernFileRO'],
               \  [&fileencoding, 'None'],
               \  [&fileformat != 'unix' ? &fileformat : "", 'None']],
               \ 'v:val[0] != ""')
  if len(info) > 0
    echon ' ['
    let separator = ''
    for [str, hlgroup] in info
      echon separator
      execute 'echohl' hlgroup
      echon str
      echohl None
      let separator = ','
    endfor
    echon ']'
  endif
  let [line, nlines, vcol, col] = [line('.'), line('$'), virtcol('.'), col('.')]
  echon ' line ' line ' of ' nlines ' (' (100 * line / nlines) '%); column ' vcol
  if col != vcol
    echon ' (byte index ' col ')'
  endif
endfunction

let &cpo = s:cpo_save
