if exists('g:quickpick_lsp_loaded')
  finish
endif
let g:quickpick_lsp_loaded = 1

command! PLspWorkspaceSymbol call quickpick#pickers#lsp#workspacesymbol#open()
command! PLspDocumentSymbol call quickpick#pickers#lsp#documentsymbol#open()

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
