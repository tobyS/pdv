================================
PDV - PHP Documentor for VIM - 2
================================

This is version 2 of **PDV - PHP Documentor for VIM**, your tool of choice for
generating PHP doc blocks. It is a complete rewrite of version 1, which
contained code written back in 2005 and earlier. As a result, the code is now
way more maintainable and you gain exciting new features:

- Templating support through Vmustache__
- Integration with UltiSnips__ to complete your docs directly after generation

__ https://github.com/tobyS/vmustache
__ https://github.com/SirVer/ultisnips

Try it out now.

------------
Requirements
------------
Vmustache__ is a required plugin for PDV to work

__ https://github.com/tobyS/vmustache 


-------
Install
-------

You should install PDV through a VIM plugin manager of your choice. I recommend
Vundle__ for that purpose, but others should work, too. With Vundle you need

__ https://github.com/gmarik/vundle

::

    Bundle 'tobyS/pdv'

in your ``.vimrc`` and then run ``:BundleInstall`` in a new VIM instance.

Before using PDV, you should map one of the following functions to a key of
your choice:

pdv#DocumentCurrentLine()
    Generates the doc block as you know it from PDV 1, but using the templates
    from your template directory.
pdv#DocumentWithSnip()
    This function requires UltiSnips__ as a prerequisite. If you have that
    installed, your templates will be used as snippets and you will be put
    into the first tab right after the doc block was generated.

__ https://github.com/SirVer/ultisnips

If you'd like to use templates other than the ones in the ``templates_snip``
directory, you should set the variable ``pdv_template_dir`` which points to
your templates.

My config for PDV looks like this::

    let g:pdv_template_dir = $HOME ."/.vim/bundle/pdv/templates_snip"
    nnoremap <buffer> <C-p> :call pdv#DocumentWithSnip()<CR>

There are examples for templates (both a non-snip and a snip version) shipped
with PDV.

..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
