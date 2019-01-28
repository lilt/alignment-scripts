#!/bin/bash

set -ex

prefix="deen"
DIR_NAME="German-English"

if [ ! -d $DIR_NAME ]; then
  wget http://statmt.org/europarl/v7/de-en.tgz
  tar -xvzf de-en.tgz
  mkdir ${DIR_NAME}
  mv europarl-v7.de-en.* ${DIR_NAME}
  rm de-en.tgz
fi

# tokenization to match the test data
${MOSES_DIR}/scripts/tokenizer/tokenizer.perl -l de -no-escape -threads 4 < ${DIR_NAME}/europarl-v7.de-en.de > ${DIR_NAME}/${prefix}.src
${MOSES_DIR}/scripts/tokenizer/tokenizer.perl -l en -no-escape -threads 4 < ${DIR_NAME}/europarl-v7.de-en.en > ${DIR_NAME}/${prefix}.tgt

../scripts/remove_sentences.py ${DIR_NAME}/${prefix} ../test/${prefix} ${prefix}

