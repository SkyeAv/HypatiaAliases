#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: cclean <nodes> <edges>"
    return 1
fi

nodes=$1
edges=$2

cd /15TB_2/sgoetz/DUPLICATE_UTILITY/duplicate-utility
lein run -n $nodes -e $edges
cd -
