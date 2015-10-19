let g:pdv_template_dir = expand("%:p:h") . "/templates"

source helpers/functions.vim

edit test006_interfaces.in

let doclines = [20, 17, 14, 10, 6, 3]
call DocumentLines(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
