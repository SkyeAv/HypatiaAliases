#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: skg <nodes> <edges>"
    return 1
fi

nodes=$1
edges=$2
output="QC.json"

/15TB_2/gglusman/translator/bin/studyKGtsvs.pl $nodes $edges $output
