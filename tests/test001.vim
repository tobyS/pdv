edit test001.in
call cursor(7, 100)
call pdv#DocumentCurrentLine()
call cursor(5, 100)
call pdv#DocumentCurrentLine()
call cursor(3, 100)
call pdv#DocumentCurrentLine()
call vimtest#SaveOut()
call vimtest#Quit()
