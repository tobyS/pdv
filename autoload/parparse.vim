func! parparse#ParseParameters(line)

	let l:context = {"pos": {"line": a:line, "col": 0}, "counter": 0, "stack": [], "return": ""}

	call s:SkipToParamList(l:context)

	" echo l:context

	while (!s:IsEndOfFile(l:context))
		let l:char = s:GetNext(l:context)

		call s:RecordBracket(l:char, l:context)

		if (s:IsEndOfParamList(l:context))
			call s:ReduceParameter(l:context)
			call s:RecordReturn(l:context)
			break
		endif

		call add(l:context["stack"], l:char)

		if (l:context["counter"] == 1 && l:char == ",")
			call s:ReduceParameter(l:context)
		endif
	endwhile
	return {"parameters": l:context["stack"], "return": l:context["return"]}
endfunc

func! s:IsEndOfParamList(context)
	return a:context["counter"] == 0
endfunc

func! s:SkipToParamList(context)
	while (!s:IsEndOfFile(a:context))
		let l:char = s:GetNext(a:context)
		call s:RecordBracket(l:char, a:context)
		if (a:context["counter"] == 1)
			break
		endif
	endwhile
endfunc

func! s:RecordBracket(char, context)
	if (a:char == "(")
		let a:context["counter"] += 1
	endif
	if (a:char == ")")
		let a:context["counter"] -= 1
	endif
endfunc!

func! s:IsEndOfFile(context)
	let l:pos = a:context["pos"]
	let l:lastline = line("$")
	let l:lastcol  = len(getline(l:lastline)) - 1
	return (l:pos["line"] >= l:lastline && s:BeyondEndOfLine(a:context))
endfunc

func! s:BeyondEndOfLine(context)
	let l:line = a:context["pos"]["line"]
	let l:lastcol  = len(getline(l:line)) - 1
	return a:context["pos"]["col"] > l:lastcol
endfunc

func! s:GetNext(context)
	if (s:BeyondEndOfLine(a:context))
		let a:context["pos"]["line"] += 1
		let a:context["pos"]["col"] = 0
	endif

	let l:line = getline(a:context["pos"]["line"])
	let l:char = strpart(l:line, a:context["pos"]["col"], 1)

	let a:context["pos"]["col"] += 1

	return l:char
endfunc

func! s:ReduceParameter(context)
	let l:param = ""
	while (!empty(a:context["stack"]))
		let l:current = remove(a:context["stack"], -1)
		if (len(l:current) > 1)
			call add(a:context["stack"], l:current)
			break
		endif
		let l:param = l:current . l:param
	endwhile
	
	let l:parammatch = matchlist(l:param, '^\s*\([^ ].*[^ ,]\),\?\s*$')

	if empty(l:parammatch)
		" Empty parameter list
		return
	endif

	let l:param = l:parammatch[1]
	call add(a:context["stack"], l:param)
endfunc


func! s:RecordReturn(context)
	let l:line = a:context["pos"]["line"]
	let l:text = getline(l:line)
	let l:matches = matchlist(l:text, ')\s*:\s*\(?*\)\s*\([a-zA-Z_0-9]\+\)')

	if(empty(l:matches))
		return
	endif

	if (l:matches[1] == '?')
    	let return = "null|".l:matches[2]
	else
		let return = l:matches[2]
	endif

	let a:context["return"] = l:return
endfunc!
