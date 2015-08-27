#!/bin/bash
runVimTests.sh --vimexecutable '/usr/bin/vim' \
    --runtime "bundle/vmustache/autoload/vmustache.vim" \
    --source "`pwd`/autoload/pdv.vim" \
    --source "`pwd`/autoload/parparse.vim" \
    ${1-tests/}

echo ""
echo "Note that tests including UltiSnips functionality fail due to missing dependency."
echo "This will be fixed."
