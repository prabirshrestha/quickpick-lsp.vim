let s:req_id = 0

function! quickpick#pickers#lsp#workspacesymbols#show() abort
	let l:servers = filter(lsp#get_whitelisted_servers(), 'lsp#capabilities#has_workspace_symbol_provider(v:val)')
    let l:id = quickpick#create({
        \   'on_change': function('s:on_change', [l:servers]),
        \   'on_accept': function('s:on_accept'),
        \   'on_close': function('s:on_close'),
        \ })
    call quickpick#show(l:id)
	call s:on_change(l:servers, l:id, 'change', '')
    return l:id
endfunction

function! s:on_change(servers, id, action, searchterm) abort
	if len(a:servers) == 0
		return
	endif
	
    call quickpick#set_busy(a:id, 1)
    if exists('s:search_timer')
        call timer_stop(s:search_timer)
        unlet s:search_timer
    endif
    let s:search_timer = timer_start(100, function('s:on_search', [a:servers, a:id, a:action, a:searchterm]))
endfunction

function! s:on_accept(id, action, data) abort
    call quickpick#close(a:id)
	" TODO: do not use internal apis
	call lsp#utils#location#_open_vim_list_item(a:data['items'][0], '')
endfunction

function! s:on_close(id, ...) abort
    if exists('s:search_timer')
        call timer_stop(s:search_timer)
        unlet s:search_timer
    endif
endfunction

function! s:on_search(servers, id, action, searchterm, ...) abort
	let s:req_id += 1
	let l:ctx = { 'results': [], 'total': len(a:servers), 'counter': 0, 'req_id': s:req_id }
	for l:server in a:servers
        call lsp#send_request(l:server, {
            \ 'method': 'workspace/symbol',
            \ 'params': {
            \   'query': a:searchterm,
            \ },
            \ 'on_notification': function('s:on_lsp_notification', [ctx, l:server, a:id]),
            \ })
	endfor
endfunction

function! s:on_lsp_notification(ctx, server, id, data) abort
	let a:ctx['counter'] += 1
	if s:req_id != a:ctx['req_id']
		return
	endif
	if lsp#client#is_error(a:data['response']) 
		call quickpick#set_busy(a:id, a:ctx['total'] != a:ctx['counter'])
        return 
	endif
	for l:item in lsp#ui#vim#utils#symbols_to_loc_list(a:server, a:data)
		let l:item['label'] = l:item['text']
		call add(a:ctx['results'], l:item)
	endfor
	call quickpick#set_busy(a:id, a:ctx['total'] != a:ctx['counter'])
	call quickpick#set_items(a:id, a:ctx['results'])
endfunction
