#!/bin/bash
~/.vim/bundle/runVimTests/bin/runVimTests.sh -2 \
    --source "`pwd`/autoload/pdv.vim" \
    --source "`pwd`/autoload/parparse.vim" \
    ${1-tests/}
