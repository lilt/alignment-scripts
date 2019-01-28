#!/bin/bash

set -ex

prefix="deen"
DIR_NAME="DeEn"

if [ ! -f DeEnGoldAlignment.tar.gz ]; then
  echo "Download file from: https://www-i6.informatik.rwth-aachen.de/goldAlignment/index.php#download"
fi

tar -xvzf DeEnGoldAlignment.tar.gz

mv ${DIR_NAME}/alignmentDeEn.talp ${prefix}.talp
iconv -f latin1 -t utf-8 < ${DIR_NAME}/de > ${prefix}.src
iconv -f latin1 -t utf-8 < ${DIR_NAME}/en > ${prefix}.tgt

