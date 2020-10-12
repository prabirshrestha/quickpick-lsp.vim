if exists('g:quickpick_lsp_loaded')
    finish
endif
let g:quickpick_lsp_loaded = 1

command! PLspWorkspaceSymbol call quickpick#pickers#lsp#workspacesymbol#open()
