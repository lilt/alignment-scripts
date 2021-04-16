#!/bin/bash

set -ex

# check if MOSES_DIR is set and installed
if [ -z ${MOSES_DIR} ]; then
  echo "Set the variable MOSES_DIR"
  exit
fi

if [ ! -f ${MOSES_DIR}/scripts/tokenizer/tokenizer.perl ]; then
  echo "Install Moses, file ${MOSES_DIR}/scripts/tokenizer/tokenizer.perl not found"
  exit
fi


prefix="roen"
EUROPARL_DIR_NAME="training-parallel-ep-v8"
DIR_NAME="Romanian-English"

# Original data of alignment paper
if [ ! -d $DIR_NAME ]; then
  wget http://web.eecs.umich.edu/~mihalcea/wpt/data.protected/Romanian-English.training.tar.gz
  tar -xvzf Romanian-English.training.tar.gz
  rm Romanian-English.training.tar.gz
fi

awk '{print $1}' < ${DIR_NAME}/FilePairs.training > ${DIR_NAME}/FilePairs.src
awk '{print $2}' < ${DIR_NAME}/FilePairs.training > ${DIR_NAME}/FilePairs.tgt

for direction in "src" "tgt"; do
  while read -r line
  do
    cat ${DIR_NAME}/training/"$line" | iconv -f latin1 -t utf-8
  done < "${DIR_NAME}/FilePairs.${direction}" > ${DIR_NAME}/${prefix}.${direction}
done

# Europarl
if [ ! -d $EUROPARL_DIR_NAME ]; then
  wget http://data.statmt.org/wmt16/translation-task/training-parallel-ep-v8.tgz
  tar -xvzf training-parallel-ep-v8.tgz
  rm training-parallel-ep-v8.tgz
fi

# tokenize
${MOSES_DIR}/scripts/tokenizer/tokenizer.perl -l ro -no-escape < ${EUROPARL_DIR_NAME}/europarl-v8.ro-en.ro > ${EUROPARL_DIR_NAME}/${prefix}.src
${MOSES_DIR}/scripts/tokenizer/tokenizer.perl -l en -no-escape < ${EUROPARL_DIR_NAME}/europarl-v8.ro-en.en > ${EUROPARL_DIR_NAME}/${prefix}.tgt

# merge
for direction in "src" "tgt"; do
  # Additionally normalize non breaking spaces to normal spaces (https://github.com/lilt/alignment-scripts/issues/7)
  cat ${DIR_NAME}/${prefix}.${direction} ${EUROPARL_DIR_NAME}/${prefix}.${direction} | sed 's/\xC2\xA0/ /g' > ${prefix}.${direction}
done

