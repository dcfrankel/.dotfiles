" Fzf settings
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --layout reverse --margin=1,4"