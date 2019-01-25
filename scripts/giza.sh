#!/bin/bash

set -e

SCRIPT_DIR=${0%/giza.sh}

# check if MGIZA_DIR is set and installed
if [ -z ${MGIZA_DIR} ]; then
  echo "Set the variable MGIZA_DIR"
  exit
fi

if [ ! -f ${MGIZA_DIR}/mgizapp/bin/mgiza ]; then
  echo "Install mgiza, file ${MGIZA_DIR}/mgizapp/bin/mgiza not found"
  exit
fi

# check parameter count and write usage instruction
if (( $# != 2 )); then
  echo "Usage: $0 source_file_path target_file_path"
  exit
fi

source_path=$1
target_path=$2
source_name=${1##*/}
target_name=${2##*/}

# creates vcb and snt files
${MGIZA_DIR}/mgizapp/bin/plain2snt $1 $2

${MGIZA_DIR}/mgizapp/bin/mkcls -n10 -p${source_path} -V${source_name}.class &
${MGIZA_DIR}/mgizapp/bin/mkcls -n10 -p${target_path} -V${target_name}.class &

${MGIZA_DIR}/mgizapp/bin/snt2cooc ${source_name}_${target_name}.cooc ${source_path}.vcb ${target_path}.vcb ${source_path}_${target_name}.snt &
${MGIZA_DIR}/mgizapp/bin/snt2cooc ${target_name}_${source_name}.cooc ${target_path}.vcb ${target_path}.vcb ${target_path}_${source_name}.snt &


mkdir -p Forward && cd $_
echo "corpusfile ${source_path}_${target_name}.snt" > config.txt
echo "sourcevocabularyfile ${source_path}.vcb" >> config.txt
echo "targetvocabularyfile ${target_path}.vcb" >> config.txt
echo "coocurrencefile ../${source_name}_${target_name}.cooc" >> config.txt
echo "sourcevocabularyclasses ../${source_name}.class" >> config.txt
echo "targetvocabularyclasses ../${target_name}.class" >> config.txt

cd ..

mkdir -p Backward && cd $_
echo "corpusfile ${target_path}_${source_name}.snt" > config.txt
echo "sourcevocabularyfile ${target_path}.vcb" >> config.txt
echo "targetvocabularyfile ${source_path}.vcb" >> config.txt
echo "coocurrencefile ../${target_name}_${source_name}.cooc" >> config.txt
echo "sourcevocabularyclasses ../${target_name}.class" >> config.txt
echo "targetvocabularyclasses ../${source_name}.class" >> config.txt
cd ..

for name in "Backward" "Forward"; do
  cd $name
    ${MGIZA_DIR}/mgizapp/bin/mgiza config.txt
    cat *A3.final.part* > allA3.txt
  cd ..
done

# convert alignments
${SCRIPT_DIR}/a3ToTalp.py < Forward/allA3.txt > alignment.talp
${SCRIPT_DIR}/a3ToTalp.py < Backward/allA3.txt > alignment.reverse.talp

