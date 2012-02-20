edit test003.in

let doclines = [25, 22, 17, 14, 10, 6, 3]

for line in doclines
	call cursor(line, 42)
	echo "Docline: " . line
	call pdv#DocumentLine()
endfor

call vimtest#SaveOut()
call vimtest#Quit()
