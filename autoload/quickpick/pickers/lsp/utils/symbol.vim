function! quickpick#pickers#lsp#utils#symbol#open(servers, typ, requestcb) abort
  if len(a:servers) == 0
    echohl ErrorMsg
    echomsg 'No LSP servers with ' . a:typ . ' support found'
    echohl NONE
    return
  endif
  call quickpick#open({
    \ 'key': 'text',
    \ 'on_open': function('s:on_open', [a:servers, a:typ, a:requestcb]),
    \ 'on_change': function('s:on_change'),
    \ 'on_accept': function('s:on_accept'),
    \ 'on_close': function('s:on_close'),
    \ })
endfunction

function! s:on_open(servers, typ, requestcb, data, ...) abort
  let s:Input = lsp#callbag#makeSubject()
  let s:Dispose = lsp#callbag#pipe(
	\ s:Input,
	\ lsp#callbag#distinctUntilChanged(),
	\ lsp#callbag#tap({_->quickpick#busy(0)}),
	\ lsp#callbag#switchMap({query->lsp#request(a:servers[0], a:requestcb(query))}),
	\ lsp#callbag#tap({data->s:set_items(a:servers, a:typ, data)}),
	\ lsp#callbag#tap({_->quickpick#busy(0)}),
	\ lsp#callbag#subscribe(),
	\ )
  " send empty string as query to trigger first result
  " most language servers usually returns empty result if query is empty
  call s:Input(1, '')
endfunction

function! s:set_items(servers, typ, data) abort
  if lsp#client#is_error(a:data['response'])
    echohl ErrorMsg
    echomsg 'Error occured retrieving LSP ' . a:typ
    echohl NONE
    return
  endif

  let l:list = lsp#ui#vim#utils#symbols_to_loc_list(a:servers[0], a:data)
  call quickpick#items(l:list)
endfunction

function! s:on_change(data, ...) abort
  call s:Input(1, a:data['input'])
endfunction

function! s:on_accept(data, ...) abort
  call quickpick#close()
  call lsp#utils#tagstack#_update()
  call lsp#utils#location#_open_vim_list_item(a:data['items'][0], '')
endfunction

function! s:on_close(...) abort
  if exists('s:Dispose')
    call s:Dispose()
    unlet s:Dispose
  endif
  unlet s:Input
endfunction

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
