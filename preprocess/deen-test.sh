#!/bin/bash

set -ex

prefix="deen"
DIR_NAME="DeEn"

if [ ! -f DeEnGoldAlignment.tar.gz ]; then
  echo "Download file from: https://www-i6.informatik.rwth-aachen.de/goldAlignment/index.php#download"
fi

tar -xvzf DeEnGoldAlignment.tar.gz

# remove empty lines
sed '/^[[:space:]]*$/d' < ${DIR_NAME}/alignmentDeEn.talp > ${prefix}.talp
cat ${DIR_NAME}/de | sed '/^[[:space:]]*$/d' | iconv -f latin1 -t utf-8 > ${prefix}.src
cat ${DIR_NAME}/en | sed '/^[[:space:]]*$/d' | iconv -f latin1 -t utf-8 > ${prefix}.tgt

