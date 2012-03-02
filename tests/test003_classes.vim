let g:pdv_template_dir = expand("%:p:h") . "/templates"

source helpers/functions.vim

edit test003_classes.in

let doclines = [25, 22, 17, 14, 10, 6, 3]
call DocumentLines(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
