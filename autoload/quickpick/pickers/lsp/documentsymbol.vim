function! quickpick#pickers#lsp#documentsymbol#open() abort
  let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_document_symbol_provider(v:val)')
  let l:textdocument = lsp#get_text_document_identifier()
  call quickpick#pickers#lsp#utils#symbol#open(l:servers, 'document symbols', {query->
    \ {
    \   'method': 'textDocument/documentSymbol',
    \   'params': {
    \     'textDocument': l:textdocument
    \   },
    \ }
    \ }, 0)
endfunction

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
