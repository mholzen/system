#!/bin/bash

# TODO: search <term> | get
# TODO: cat data | get [<context>]
#        interpret data as a resource description (with <context> as hint)
#        and output the content

arg="$1"
type=$(type -t $arg)

if [ "$type" == 'file' ]; then    # executable
  cat `/usr/bin/which "$arg"`
  exit
fi

# search limit:1 type:file "$@" | map augment content | view
search limit:1 type:file "$@" | map content
