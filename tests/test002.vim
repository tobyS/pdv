edit test002.in

let doclines = [48, 46, 42, 38, 30, 27, 24, 20, 17, 13, 9, 6]

for line in doclines
	call cursor(line, 23)
	echo "Docline: " . line
	call pdv#DocumentLine()
endfor

call vimtest#SaveOut()
call vimtest#Quit()
