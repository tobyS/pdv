let g:pdv_template_dir = expand("%:p:h") . "/templates_snip"

source helpers/functions.vim

edit test004_attributes_snipmate.in

let doclines = [7, 5, 3]
call DocumentLinesWithSnip(doclines)

call vimtest#SaveOut()
call vimtest#Quit()
