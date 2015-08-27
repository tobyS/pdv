#!/bin/bash
runVimTests.sh --vimexecutable '/usr/bin/vim' --runtime "bundle/vmustache/autoload/vmustache.vim" --source "`pwd`/autoload/pdv.vim" --source "`pwd`/autoload/parparse.vim" ${1-tests/}
