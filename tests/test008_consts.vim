let g:pdv_template_dir = expand("%:p:h") . "/templates"

source helpers/functions.vim

edit test008_consts.in

let doclines = [9, 6, 3]
call DocumentLines(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
