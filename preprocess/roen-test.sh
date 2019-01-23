#!/bin/bash

set -ex

mkdir -p test/roen && cd $_

DIR_NAME="Romanian-English"

if [ ! -d $DIR_NAME ]; then
  wget http://web.eecs.umich.edu/\~mihalcea/wpt/data/Romanian-English.test.tar.gz
  tar -xvzf Romanian-English.test.tar.gz
  rm Romanian-English.test.tar.gz
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

cat test.e | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > test.src
cat test.r | sed -e "s/^<s[^>]*> //g" -e "s|</s>$||g" > test.tgt
rm test.e test.r

for suffix in "src" "tgt"; do
  cat test.${suffix} | tr '[:upper:]' '[:lower:]' > test.lc.${suffix}
done

../../scripts/toTalp.py < ${DIR_NAME}/answers/test.wa.nonullalign > test.talp
