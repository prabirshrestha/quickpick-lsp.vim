function! quickpick#pickers#lsp#workspacesymbol#open() abort
  let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_workspace_symbol_provider(v:val)')
  call quickpick#pickers#lsp#utils#symbol#open(l:servers, 'workspace symbols', {query->
    \ {
    \   'method': 'workspace/symbol',
    \   'params': {
    \     'query': query,
    \   },
    \ }
    \ })
endfunction

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
