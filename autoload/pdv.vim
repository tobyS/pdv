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
" - Consts
" - Interfaces
" - Traits
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
" You can use this script by mapping the function pdv#DocumentCurrentLine() to
" any key combination. Hit this on the line where the element to document
" resides and the doc block will be created directly above that line.

let s:old_cpo = &cpo
set cpo&vim

"
" Regular expressions 
" 

let s:comment = ' *\*/ *'

let s:regex = {}

" (private|protected|public)
let s:regex["scope"] = '\(private\|protected\|public\)'
" (static)
let s:regex["static"] = '\(static\)'
" (abstract)
let s:regex["abstract"] = '\(abstract\)'
" (final)
let s:regex["final"] = '\(final\)'

" [:space:]*(private|protected|public|static|abstract)*[:space:]+[:identifier:]+\([:params:]\)
let s:regex["function"] = '^\(\s*\)\([a-zA-Z ]*\)function\s\+\([^ (]\+\)\s*('
" [:typehint:]*[:space:]*$[:identifier]\([:space:]*=[:space:]*[:value:]\)?
let s:regex["param"] = ' *\([^ &]*\)\s*\(&\?\)\$\([^ =)]\+\)\s*\(=\s*\(.*\)\)\?$'

" ^(?<indent>\s*)const\s+(?<name>\S+)\s*=
" 1:indent, 2:name
let s:regex["const"] = '^\(\s*\)const\s\+\(\S\+\)\s*='

" [:space:]*(private|protected|public\)[:space:]*$[:identifier:]+\([:space:]*=[:space:]*[:value:]+\)*;
let s:regex["attribute"] = '^\(\s*\)\(\(private\s*\|public\s*\|protected\s*\|static\s*\)\+\)\s*\$\([^ ;=]\+\)[ =]*\(.*\);\?$'

" [:spacce:]*(abstract|final|)[:space:]*(class|interface)+[:space:]+\(extends ([:identifier:])\)?[:space:]*\(implements ([:identifier:][, ]*)+\)?

let s:regex["class"] = '^\(\s*\)\(\S*\)\s*\(class\)\s*\(\S\+\)\s*\([^{]*\){\?$'

" ^(?<indent>\s*)interface\s+(?<name>\S+)(\s+extends\s+(?<interface>\s+)(\s*,\s*(?<interface>\S+))*)?\s*{?\s*$
" 1:indent, 2:name, 4,6,8,...:extended interfaces
let s:regex["interface"] = '^\(\s*\)interface\s\+\(\S\+\)\(\s\+extends\s\+\(\S\+\)\(\s*,\s*\(\S\+\)\)*\)\?\s*{\?\s*$'

" ^(?<indent>\s*)trait\s+(?<name>\S+)\s*{?\s*$
" 1:indent, 2:name
let s:regex["trait"] = '^\(\s*\)trait\s\+\(\S\+\)\s*{\?\s*$'

let s:regex["variable"] = '^\(\s*\)\(\$[^ =]\+\)\s*=\s*\([^;]\+\);$'
let s:regex["newobject"] = '^\s*new\s*\([^(;]\+\).*$'

let s:regex["types"] = {}

let s:regex["types"]["array"]  = "^array *(.*"
let s:regex["types"]["float"]  = '^[0-9]*\.[0-9]\+'
let s:regex["types"]["int"]    = '^[0-9]\+'
let s:regex["types"]["string"] = "['\"].*"
let s:regex["types"]["bool"] = "\(true\|false\)"

let s:regex["indent"] = '^\s*'

let s:mapping = [
    \ {"regex": s:regex["function"],
    \  "function": function("pdv#ParseFunctionData"),
    \  "template": "function"},
    \ {"regex": s:regex["attribute"],
    \  "function": function("pdv#ParseAttributeData"),
    \  "template": "attribute"},
    \ {"regex": s:regex["const"],
    \  "function": function("pdv#ParseConstData"),
    \  "template": "const"},
    \ {"regex": s:regex["class"],
    \  "function": function("pdv#ParseClassData"),
    \  "template": "class"},
    \ {"regex": s:regex["interface"],
    \  "function": function("pdv#ParseInterfaceData"),
    \  "template": "interface"},
    \ {"regex": s:regex["trait"],
    \  "function": function("pdv#ParseTraitData"),
    \  "template": "trait"},
    \ {"regex": s:regex["variable"],
    \  "function": function("pdv#ParseVariableData"),
    \  "template": "variable"},
\ ]

func! pdv#DocumentCurrentLine()
	let l:docline = line(".")
	let l:linecontent = getline(l:docline)
	call pdv#DocumentLine(l:docline)
endfunc

func! pdv#DocumentLine(lineno)
	let l:parseconfig = s:DetermineParseConfig(getline(a:lineno))
	let l:data = s:ParseDocData(a:lineno, l:parseconfig)
	let l:docblock = s:GenerateDocumentation(l:parseconfig, l:data)

	call append(a:lineno - 1, s:ApplyIndent(l:docblock, l:data["indent"]))
	" TODO: Assumes phpDoc style comments (indent + 4).
	call cursor(a:lineno + 1, len(l:data["indent"]) + 4)
endfunc

func! pdv#DocumentWithSnip()
	let l:docline = line(".")

	let l:parseconfig = s:DetermineParseConfig(getline(l:docline))
	let l:data = s:ParseDocData(l:docline, l:parseconfig)
	let l:docblock = s:GenerateDocumentation(l:parseconfig, l:data)
    let l:snippet = join(s:ApplyIndent(l:docblock, l:data["indent"]), "\n")

	let l:indent = l:data["indent"]

	call append(l:docline - 1, [""])
	call cursor(l:docline, 0)

    call UltiSnips#Anon(l:snippet)
endfunc

func! s:DetermineParseConfig(line)
	for l:parseconfig in s:mapping
		if match(a:line, l:parseconfig["regex"]) > -1
			return l:parseconfig
		endif
	endfor
	throw "Could not detect parse config for '" . a:line . "'"
endfunc

func! s:ParseDocData(docline, config)
	let l:Parsefunction = a:config["function"]
	return l:Parsefunction(a:docline)
endfunc

func! s:GenerateDocumentation(config, data)
	let l:template = s:GetTemplate(a:config["template"] . '.tpl')
	return s:ProcessTemplate(l:template, a:data)
endfunc

func! s:GetTemplate(filename)
	return g:pdv_template_dir . '/' . a:filename
endfunc

func! s:ProcessTemplate(file, data)
	return vmustache#RenderFile(a:file, a:data)
endfunc

func! s:ApplyIndent(text, indent)
	let l:lines = split(a:text, "\n")
	return map(l:lines, '"' . a:indent . '" . v:val')
endfunc

func! pdv#ParseClassData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["class"])

	let l:data["indent"] = matches[1]
	let l:data["name"] = matches[4]
	let l:data["abstract"] = s:GetAbstract(matches[2])
	let l:data["final"] = s:GetFinal(matches[2])

	if (!empty(l:matches[5]))
		call s:ParseExtendsImplements(l:data, l:matches[5])
	endif
	" TODO: abstract? final?

	return l:data
endfunc

" ^(?<indent>\s*)interface\s+(?<name>\S+)(\s+extends\s+(?<interface>\s+)(\s*,\s*(?<interface>\S+))*)?\s*{?\s*$
" 1:indent, 2:name, 4,6,8,...:extended interfaces
func! pdv#ParseInterfaceData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["interface"])

	let l:data["indent"] = matches[1]
	let l:data["name"] = matches[2]

	let l:data["parents"] = []

	let i = 2
	while !empty(l:matches[i+2])
		let i += 2
		let l:data["parents"] += [{"name":matches[i]}]
	endwhile

	return l:data
endfunc

" ^(?<indent>\s*)trait\s+(?<name>\S+)\s*{?\s*$
" 1:indent, 2:name
func! pdv#ParseTraitData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["trait"])

	let l:data["indent"] = matches[1]
	let l:data["name"] = matches[2]

	return l:data
endfunc

func! pdv#ParseVariableData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["variable"])

	let l:data["indent"] = l:matches[1]
	let l:data["name"] = l:matches[2]
	" TODO: Cleanup ; and friends
	let l:data["default"] = get(l:matches, 3, '')

	let l:types = matchlist(l:matches[3], s:regex["newobject"])
	if (!empty(l:types))
		let l:data["type"] = l:types[1]
	elseif (!empty(l:data["default"]))
		let l:data["type"] = s:GuessType(l:data["default"])
	endif

	return l:data
endfunc


func! s:ParseExtendsImplements(data, text)
	let l:tokens = split(a:text, '\(\s*,\s*\|\s\+\)')

	let l:extends = 0
	for l:token in l:tokens
		if (tolower(l:token) == "extends")
			let l:extends = 1
			continue
		endif
		if l:extends
			let a:data["parent"] = [{"name": l:token}]
			break
		endif
	endfor

	let l:implements = 0
	let l:interfaces = []
	for l:token in l:tokens
		if (tolower(l:token) == "implements")
			let l:implements = 1
			continue
		endif
		if (l:implements && tolower(l:token) == "extends")
			break
		endif
		if (l:implements)
			call add(l:interfaces, {"name": l:token})
		endif
	endfor
	let a:data["interfaces"] = l:interfaces

endfunc

" ^(?<indent>\s*)const\s+(?<name>\S+)\s*=
" 1:indent, 2:name
func! pdv#ParseConstData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["const"])

	let l:data["indent"] = l:matches[1]
	let l:data["name"] = l:matches[2]

	return l:data
endfunc

func! pdv#ParseAttributeData(line)
	let l:text = getline(a:line)

	let l:data = {}
	let l:matches = matchlist(l:text, s:regex["attribute"])

	let l:data["indent"] = l:matches[1]
	let l:data["scope"] = s:GetScope(l:matches[2])
	let l:data["static"] = s:GetStatic(l:matches[2])
	let l:data["name"] = l:matches[4]
	" TODO: Cleanup ; and friends
	let l:data["default"] = get(l:matches, 5, '')
	let l:data["type"] = s:GuessType(l:data["default"])

	return l:data
endfunc

func! pdv#ParseFunctionData(line)
	let l:text = getline(a:line)

	let l:data = s:ParseBasicFunctionData(l:text)
	let l:data["parameters"] = []

	let l:functionData = parparse#ParseParameters(a:line)
	let l:parameters = l:functionData["parameters"]

	for l:param in l:parameters
		call add(l:data["parameters"], s:ParseParameterData(l:param))
	endfor

	if (l:functionData["return"] != "")
		let l:data["return"] = l:functionData["return"]
	endif

	return l:data
endfunc

func! s:ParseParameterData(text)
	let l:data = {}

	let l:matches = matchlist(a:text, s:regex["param"])

	let l:data["reference"] = (l:matches[2] == "&")
	let l:data["name"] = l:matches[3]
	let l:data["default"] = l:matches[5]

	if (!empty(l:matches[1]))
		let l:data["type"] = l:matches[1]
	elseif (!empty(l:data["default"]))
		let l:data["type"] = s:GuessType(l:data["default"])
	endif

	return l:data
endfunc

func! s:ParseBasicFunctionData(text)
	let l:data = {}

	let l:matches = matchlist(a:text, s:regex["function"])

	let l:data["indent"] = l:matches[1]
	let l:data["scope"] = s:GetScope(l:matches[2])
	let l:data["static"] = s:GetStatic(l:matches[2])
	let l:data["name"] = l:matches[3]

	return l:data
endfunc

func! s:GetScope( modifiers )
	return matchstr(a:modifiers, s:regex["scope"])
endfunc

func! s:GetStatic( modifiers )
	return tolower(a:modifiers) =~ s:regex["static"]
endfunc

func! s:GetAbstract( modifiers )
	return tolower(a:modifiers) =~ s:regex["abstract"]
endfunc

func! s:GetFinal( modifiers )
	return tolower(a:modifiers) =~ s:regex["final"]
endfunc

func! s:GuessType( typeString )
	if a:typeString =~ s:regex["types"]["array"]
		return "array"
	endif
	if a:typeString =~ s:regex["types"]["float"]
		return "float"
	endif
	if a:typeString =~ s:regex["types"]["int"]
		return "int"
	endif
	if a:typeString =~ s:regex["types"]["string"]
		return "string"
	endif
	if a:typeString =~ s:regex["types"]["bool"]
		return "bool"
	endif
endfunc

let &cpo = s:old_cpo
