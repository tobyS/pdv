edit test001.in
call cursor(7, 100)
call pdv#DocumentLine()
call cursor(5, 100)
call pdv#DocumentLine()
call cursor(3, 100)
call pdv#DocumentLine()
call vimtest#SaveOut()
call vimtest#Quit()
