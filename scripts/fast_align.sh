#!/bin/bash

set -ex

# check parameter count and write usage instruction
if (( $# != 2 )); then
  echo "Usage: $0 source_file_path target_file_path"
  exit
fi

source_path=$1
target_path=$2
source_name=${1##*/}
target_name=${2##*/}

# create format used for fastalign
paste -d "~" ${source_path} ${target_path} | sed 's/~/ ||| /g' | tr '[:upper:]' '[:lower:]' > ${source_name}_${target_name}
paste -d "~" ${target_path} ${source_path} | sed 's/~/ ||| /g' | tr '[:upper:]' '[:lower:]' > ${target_name}_${source_name}

# remove lines which have an empty source or target
sed -e '/^ |||/d' -e '/||| $/d' ${source_name}_${target_name} > ${source_name}_${target_name}.clean
sed -e '/^ |||/d' -e '/||| $/d' ${target_name}_${source_name} > ${target_name}_${source_name}.clean

# align in both directions
/home/thomaszenkel/GitRepos/fast_align/build/fast_align -i ${source_name}_${target_name}.clean -d -o -v > alignment.talp
/home/thomaszenkel/GitRepos/fast_align/build/fast_align -i ${target_name}_${source_name}.clean -d -o -v > alignment.reverse.talp

