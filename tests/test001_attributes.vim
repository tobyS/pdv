let g:pdv_template_dir = expand("%:p:h") . "/templates"

source helpers/functions.vim

edit test001_attributes.in

let doclines = [7, 5, 3]
call DocumentLines(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
