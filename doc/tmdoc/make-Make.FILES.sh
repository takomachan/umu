#!/usr/bin/env sh

rake -C ../../lib/umu -f Rakefile files | \
    awk 'BEGIN { printf "FILES = \\\n" }
         { printf "\t%s \\\n", $1 }
    ' > Make.FILES
