#!/bin/zsh

source ${HOME}/.config/yadm/utils.sh

cd ~/Projects

run mkdir -p scripts

# ================================================================================================
# matrixorigin

run mkdir -p matrixorigin

run cd matrixorigin

if ! directory_exists matrixone; then
    run git clone git@github.com:jensenojs/matrixone.git
fi

if ! directory_exists docs; then
    run git clone git@github.com:jensenojs/modocs.git
fi

if ! directory_exists mo-tester; then
    run git clone git@github.com:matrixorigin/mo-tester.git
fi

if ! directory_exists mo-sysbench; then
    run git clone git@github.com:matrixorigin/mo-sysbench.git
fi

if ! directory_exists mo-load; then
    run git clone git@github.com:matrixorigin/mo-load.git
fi

# ================================================================================================
# database

run cd ~/Projects

run mkdir -p Databases

if ! directory_exists velox; then
    run git clone git@github.com:jensenojs/velox.git
fi

if ! directory_exists duckdb; then
    run git clone git@github.com:jensenojs/duckdb.git
fi

if ! directory_exists rocksdb; then
    run git clone git@github.com:jensenojs/rocksdb.git
fi

if ! directory_exists ClickHouse; then
    run git clone git@github.com:jensenojs/ClickHouse.git
fi

if ! directory_exists leveldb-with-annotation; then
    run git clone git@github.com:jensenojs/leveldb-with-annotation.git
fi

if ! directory_exists redis; then
    run git clone git@github.com:jensenojs/redis.git
fi


# ================================================================================================
# quant

cd ~/Projects

mkdir -p quant

if ! directory_exists evaluate-factor; then
    run git clone git@github.com:jensenojs/evaluate-factor.git
fi

if ! directory_exists qlib; then
    run git clone git@github.com:jensenojs/qlib.git
fi


# ================================================================================================
# paper

cd ~/Projects

mkdir -p Paper
