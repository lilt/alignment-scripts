#!/bin/bash

set -e

# check if MGIZA_DIR is set and installed
if [ -z ${FASTALIGN_DIR} ]; then
  echo "Set the variable FASTALIGN_DIR"
  exit 1
fi

if [ ! -f ${FASTALIGN_DIR}/build/fast_align ]; then
  echo "Install fastalign, file ${FASTALIGN_DIR}/build/fast_align not found"
  exit 1
fi

# check parameter count and write usage instruction
if (( $# != 3 )); then
  echo "Usage: $0 source_file_path target_file_path direction"
  exit 1
fi

source_path=$1
target_path=$2
source_name=${1##*/}
target_name=${2##*/}
direction=$3

# create format used for fastalign
paste ${source_path} ${target_path} | sed -E 's/\t/ ||| /g' > ${source_name}_${target_name}
paste ${target_path} ${source_path} | sed -E 's/\t/ ||| /g' > ${target_name}_${source_name}

# remove lines which have an empty source or target
sed -e '/^ |||/d' -e '/||| $/d' ${source_name}_${target_name} > ${source_name}_${target_name}.clean
sed -e '/^ |||/d' -e '/||| $/d' ${target_name}_${source_name} > ${target_name}_${source_name}.clean

# align in both directions
${FASTALIGN_DIR}/build/fast_align -i ${source_name}_${target_name}.clean -p ${direction}.model -d -o -v > ${direction}.talp 2> ${direction}.error
${FASTALIGN_DIR}/build/fast_align -i ${target_name}_${source_name}.clean -p ${direction}.reverse.model -d -o -v > ${direction}.reverse.talp 2> ${direction}.reverse.error

