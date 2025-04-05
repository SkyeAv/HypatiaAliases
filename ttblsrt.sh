#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: ttblsrt <kg_config>"
    return 1
fi

kg_config=$1
int_dir="tablassert/"
tblsrt_path="/15TB_2/sgoetz/Tablassert"

python3 -m venv venv
source venv/bin/activate
pip install -e $tblsrt_path
download_dependencies
tablassert_test
pkill tablassert
rm nohup.out
rm -rf $int_dir
nohup time tablassert $kg_config
deactivate
