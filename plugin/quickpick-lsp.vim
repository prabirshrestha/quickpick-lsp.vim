if exists('g:quickpick_lsp')
    finish
endif
let g:quickpick_lsp = 1

" command! Pnpm call quickpick#pickers#npm#show()
command! Plspworkspacesymbols call quickpick#pickers#lsp#workspacesymbols#show()
