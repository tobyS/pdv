" PDV (phpDocumentor for Vim)
" ===========================
"
" Version: 2.0.0alpha1
" 
" Copyright 2005-2011 by Tobias Schlitt <toby@php.net>
"
" Provided under the GPL (http://www.gnu.org/copyleft/gpl.html).
"
" This script provides functions to generate phpDocumentor conform
" documentation blocks for your PHP code. The script currently
" documents:
" 
" - Classes
" - Methods/Functions
" - Attributes
"
" All of those supporting PHP 5 syntax elements. 
"
" Beside that it allows you to define default values for phpDocumentor tags 
" like @version (I use $id$ here), @author, @license and so on. 
"
" For function/method parameters and attributes, the script tries to guess the 
" type as good as possible from PHP5 type hints or default values (array, bool, 
" int, string...).
"
" You can use this script by mapping the function PhpDoc() to any
" key combination. Hit this on the line where the element to document
" resides and the doc block will be created directly above that line.

" {{{ Globals

" Default values
let g:pdv_cfg_Type = "mixed"
" let g:pdv_cfg_Package = "Framework"
" let g:pdv_cfg_Package = "Webdav"
let g:pdv_cfg_Package = "qaVoice"
let g:pdv_cfg_Version = ""
let g:pdv_cfg_Author = "Tobias Schlitt <toby@qafoo.com>"
let g:pdv_cfg_Copyright = "Copyright (C) 2010 Qafoo GmbH. All rights reserved."
let g:pdv_cfg_License = ""

let g:pdv_cfg_ReturnVal = "void"

"
" Regular expressions 
" 

let g:pdv_re_comment = ' *\*/ *'

" (private|protected|public)
let g:pdv_re_scope = '\(private\|protected\|public\)'
" (static)
let g:pdv_re_static = '\(static\)'
" (abstract)
let g:pdv_re_abstract = '\(abstract\)'
" (final)
let g:pdv_re_final = '\(final\)'

" [:space:]*(private|protected|public|static|abstract)*[:space:]+[:identifier:]+\([:params:]\)
let g:pdv_re_func = '^\s*\([a-zA-Z ]*\)function\s\+\([^ (]\+\)\s*(\s*\(.*\)\s*)\s*[{;]\?$'
" [:typehint:]*[:space:]*$[:identifier]\([:space:]*=[:space:]*[:value:]\)?
let g:pdv_re_param = ' *\([^ &]*\) *&\?\$\([A-Za-z_][A-Za-z0-9_]*\) *=\? *\(.*\)\?$'

" [:space:]*(private|protected|public\)[:space:]*$[:identifier:]+\([:space:]*=[:space:]*[:value:]+\)*;
let g:pdv_re_attribute = '^\(\s*\)\(\(private\s*\|public\s*\|protected\s*\|static\s*\)\+\)\s*\$\([^ ;=]\+\)[ =]*\(.*\);\?$'

" [:spacce:]*(abstract|final|)[:space:]*(class|interface)+[:space:]+\(extends ([:identifier:])\)?[:space:]*\(implements ([:identifier:][, ]*)+\)?
let g:pdv_re_class = '^\s*\([a-zA-Z]*\)\s*\(interface\|class\)\s*\([^ ]\+\)\s*\(extends\)\?\s*\([a-zA-Z0-9]*\)\?\s*\(implements*\)\? *\([a-zA-Z0-9_ ,]*\)\?.*$'

let g:pdv_re_array  = "^array *(.*"
" FIXME (retest regex!)
let g:pdv_re_float  = '^[0-9]*\.[0-9]\+'
let g:pdv_re_int    = '^[0-9]\+'
let g:pdv_re_string = "['\"].*"
let g:pdv_re_bool = "\(true\|false\)"

let g:pdv_re_indent = '^\s*'

" Shortcuts for editing the text:
let g:pdv_cfg_BOL = "norm! o"
let g:pdv_cfg_EOL = ""

" }}}  

func! pdv#DocumentLine()
	let l:docline = line(".")
	let l:data = pdv#DocumentAttribute(getline(l:docline))
	call append(line(".") - 1, pdv#ProcessTemplate(pdv#GetTemplate('attribute.tpl'), l:data))
	" TODO: Assumes phpDoc style comments (indent + 4).
	call cursor(l:docline + 1, len(l:data["indent"]) + 4)
endfunc

func! pdv#GetTemplate(filename)
	return g:pdv_template_dir . '/' . a:filename
endfunc

func! pdv#ProcessTemplate(file, data)
	let l:lines = readfile(a:file)
	let l:i = 0
	while l:i < len(l:lines)
		for l:key in keys(a:data)
			let l:regex = '{' . l:key . '}'
			let l:lines[l:i] = substitute(l:lines[l:i], l:regex, a:data[l:key], 'g')
		endfor
		let l:lines[l:i] = a:data["indent"] . l:lines[l:i]
		let l:i += 1
	endwhile
	return l:lines
endfunc

func! pdv#DocumentAttribute(text)
	let l:data = {}
	let l:matches = matchlist(a:text, g:pdv_re_attribute)

	" return l:matches
	" ['    public static $lala = 23;', '    ', 'public static ', 'static ', 'lala', '23;', '', '', '', '']

	let l:data["indent"] = l:matches[1]
	let l:data["scope"] = pdv#GetScope(l:matches[2])
	let l:data["static"] = pdv#GetStatic(l:matches[2])
	let l:data["name"] = l:matches[4]
	" TODO: Cleanup ; and friends
	let l:data["default"] = get(l:matches, 5, '')
	let l:data["type"] = pdv#GuessType(l:data["default"])

	return l:data
endfunc

func! pdv#GetScope( modifiers )
	return matchstr(a:modifiers, g:pdv_re_scope)
endfunc

func! pdv#GetStatic( modifiers )
	return matchstr(a:modifiers, g:pdv_re_static) == 'static'
endfunc

func! pdv#GuessType( typeString )
	let l:type = ""
	if a:typeString =~ g:pdv_re_array
		let l:type = "array"
	endif
	if a:typeString =~ g:pdv_re_float
		let l:type = "float"
	endif
	if a:typeString =~ g:pdv_re_int
		let l:type = "int"
	endif
	if a:typeString =~ g:pdv_re_string
		let l:type = "string"
	endif
	if a:typeString =~ g:pdv_re_bool
		let l:type = "bool"
	endif
	if l:type == ""
		let l:type = g:pdv_cfg_Type
	endif
	return l:type
endfunc
