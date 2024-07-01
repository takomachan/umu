#!/usr/bin/env sh

make -C ../lib/umu -f Makefile files | \
    awk 'BEGIN { printf "FILES = \\\n" }
         { printf "\t%s \\\n", $1 }
    ' > Make.FILES
