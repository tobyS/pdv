let g:pdv_template_dir = expand("%:p:h") . "/templates_snip"

source helpers/functions.vim

edit test005_functions_snipmate.in

let doclines = [48, 46, 42, 38, 30, 27, 24, 20, 17, 13, 9, 6]
call DocumentLinesWithSnip(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
