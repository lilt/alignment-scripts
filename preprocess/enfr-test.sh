#!/bin/bash

set -ex

prefix="enfr"
DIR_NAME="English-French"

if [ ! -d $DIR_NAME ]; then
  for dataset in "test" "trial"; do
    # Both get unpacked into the DIR_NAME Directory
    wget http://web.eecs.umich.edu/\~mihalcea/wpt/data/English-French.${dataset}.tar.gz
    tar -xvzf English-French.${dataset}.tar.gz
    rm English-French.${dataset}.tar.gz
  done
fi



# Bitext
for dataset in "test" "trial"; do
  cat ${DIR_NAME}/${dataset}/${dataset}.e | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" | iconv -f latin1 -t utf-8 > ${prefix}.${dataset}.src
  cat ${DIR_NAME}/${dataset}/${dataset}.f | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" | iconv -f latin1 -t utf-8 > ${prefix}.${dataset}.tgt
done

for direction in "src" "tgt"; do
  mv ${prefix}.test.${direction} ${prefix}.${direction}
done

# Alignments
../scripts/toTalp.py < ${DIR_NAME}/answers/test.wa.nonullalign > ${prefix}.talp
../scripts/toTalp.py < ${DIR_NAME}/trial/trial.wa > ${prefix}.trial.talp

