let g:pdv_template_dir = expand("%:p:h") . "/templates"

source helpers/functions.vim

edit test002_functions.in

let doclines = [48, 46, 42, 38, 30, 27, 24, 20, 17, 13, 9, 6]
call DocumentLines(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
