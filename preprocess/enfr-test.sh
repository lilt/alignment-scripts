#!/bin/bash

set -ex

prefix="enfr"
DIR_NAME="English-French"

if [ ! -d $DIR_NAME ]; then
  wget http://web.eecs.umich.edu/\~mihalcea/wpt/data/English-French.test.tar.gz
  tar -xvzf English-French.test.tar.gz
  rm English-French.test.tar.gz
fi

# Bitext
cat ${DIR_NAME}/test/test.e | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" | iconv -f latin1 -t utf-8 > ${prefix}.src
cat ${DIR_NAME}/test/test.f | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" | iconv -f latin1 -t utf-8 > ${prefix}.tgt

# Alignments
../scripts/toTalp.py < ${DIR_NAME}/answers/test.wa.nonullalign > ${prefix}.talp

