if exists('g:quickpick_lsp_loaded')
    finish
endif
let g:quickpick_lsp_loaded = 1

command! PLspWorkspaceSymbols call quickpick#pickers#lsp#workspacesymbols#open()
