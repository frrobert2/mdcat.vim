vim9script

def ErrorMsg(msg: string)
	echohl ErrorMsg | echomsg msg | echohl None
enddef

def CheckFiletypes(path: string): bool
	
	var extension = expand('%:e')	# Get the file extension
	
	if !empty(path) 
		extension = fnamemodify(path, ':e')	# Get the file extension
	endif 

	var allowed_filetypes = ["md", "markdown", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd"]

	var ft_found = false
	for ft in allowed_filetypes
		if extension == ft
			ft_found = true
			break
		endif
	endfor

	if ft_found == false
		echohl WarningMsg
		echo 'mdcat only supports markdown files'
		echohl None
		return false
	endif

	return true
enddef

def Openmdcat(mods: string, path: string)
	if !executable('mdcat')
		ErrorMsg('mdcat is not installed. Please visit https://github.com/swsnr/mdcat and follow the instructions!')
		return
	endif

	if !CheckFiletypes(path)
		return
	endif

	const file: string = path ?? expand('%')

	if !file->fnamemodify(':p')->filereadable()
		ErrorMsg($'File not readable: {file}')
		return
	endif

	const ptybuf: number = term_start(['mdcat', file], {
		norestore: true,
		term_name: $'mdcat {file}',
		hidden: true,
		curwin: true,
		term_cols: 1000,
		term_finish: 'open',
		term_opencmd: $'{mods} sbuffer %d'
		})

	setbufvar(ptybuf, '&bufhidden', 'wipe')
enddef


def OpenmdcatSplit(mods: string, path: string)
	if !executable('mdcat')
		ErrorMsg('mdcat is not installed. Please visit https://github.com/swsnr/mdcat and follow the instructions!')
		return
	endif

	if !CheckFiletypes(path)
		return
	endif

	const file: string = path ?? expand('%')

	if !file->fnamemodify(':p')->filereadable()
		ErrorMsg($'File not readable: {file}')
		return
	endif

	const ptybuf: number = term_start(['mdcat', file], {
		norestore: true,
		term_name: $'mdcat {file}',
		hidden: true,
		term_cols: 1000,
		term_finish: 'open',
		term_opencmd: $'{mods} sbuffer %d'
		})

	setbufvar(ptybuf, '&bufhidden', 'wipe')
enddef

def OpenmdcatPop(mods: string, path: string)

	if !executable('mdcat')
		ErrorMsg('mdcat is not installed. Please visit hhttps://github.com/swsnr/mdcat and follow the instructions!')
		return
	endif

	if !CheckFiletypes(path)
		return
	endif

	const file: string = path ?? expand('%')

	if !file->fnamemodify(':p')->filereadable()
		ErrorMsg($'File not readable: {file}')
		return
	endif

	var ptybuf: number

	ptybuf = term_start(['mdcat', file], {
		norestore: true,
		term_name: $'mdcat {file}',
		hidden: true,
		term_highlight: 'Pmenu',
		exit_cb: (_, _) => popup_create(ptybuf, {
			title: $' mdcat {file} ',
			hidden: false,
			border: [],
			borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
			padding: [0, 1, 0, 1],
			minwidth: floor(&columns * 0.5)->float2nr(),
			maxwidth: floor(&columns * 0.8)->float2nr(),
			minheight: floor(&lines * 0.8)->float2nr(),
			maxheight: floor(&lines * 0.8)->float2nr(),
			})
		})

	setbufvar(ptybuf, '&bufhidden', 'delete')
enddef


command -nargs=? -complete=file MDcat Openmdcat(<q-mods>, <q-args>)
command -nargs=? -complete=file MDcatsplit OpenmdcatSplit(<q-mods>, <q-args>)
command -nargs=? -complete=file MDcatpop OpenmdcatPop(<q-mods>, <q-args>)

