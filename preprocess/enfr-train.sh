#!/bin/bash

set -ex

prefix="enfr"
DIR_NAME="English-French"

if [ ! -d $DIR_NAME ]; then
  wget http://web.eecs.umich.edu/\~mihalcea/wpt/data/English-French.training.tar.gz
  tar -xvzf English-French.training.tar.gz
  rm English-French.training.tar.gz
fi

# Bitext
cat ${DIR_NAME}/training/*.e | iconv -f latin1 -t utf-8 > ${prefix}.src
cat ${DIR_NAME}/training/*.f | iconv -f latin1 -t utf-8 > ${prefix}.tgt

