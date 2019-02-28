#!/bin/bash

set -ex

prefix="roen"
DIR_NAME="Romanian-English"

if [ ! -d $DIR_NAME ]; then
  for dataset in "test" "trial"; do
    wget http://web.eecs.umich.edu/\~mihalcea/wpt/data/Romanian-English.${dataset}.tar.gz
    tar -xvzf Romanian-English.${dataset}.tar.gz
    rm Romanian-English.${dataset}.tar.gz
  done
fi

# Bitext
## explicitly specify order for concatenation (I'm sure this could be done easier)
for suffix in "e" "r"; do
  files=""
  for i in 1 2 3 4 5 6 7 8 9 10; do
    files="${files} ${DIR_NAME}/test/test.${i}.${suffix}"
  done
  cat $files > "test.${suffix}"
done

cat test.r | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > ${prefix}.src
cat test.e | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > ${prefix}.tgt
rm test.e test.r
cat ${DIR_NAME}/trial/trial.r | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > ${prefix}.trial.src
cat ${DIR_NAME}/trial/trial.e | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > ${prefix}.trial.tgt

# Alignments
../scripts/toTalp.py < ${DIR_NAME}/answers/test.wa.nonullalign > ${prefix}.talp
../scripts/toTalp.py < ${DIR_NAME}/trial/trial.wa > ${prefix}.trial.talp

