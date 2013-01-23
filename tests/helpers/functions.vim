func! DocumentLines(doclines)
	for l:line in a:doclines
		call cursor(l:line, 23)
		echo "Docline: " . l:line
		call pdv#DocumentCurrentLine()
	endfor
endfunc

func! DocumentLinesWithSnip(doclines)
	for l:line in a:doclines
		call cursor(l:line, 23)
		echo "Docline: " . l:line
		call pdv#DocumentWithSnip()
	endfor
endfunc
