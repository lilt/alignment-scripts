#!/bin/bash

set -ex

SCRIPT_DIR=${0%/combine.sh}

# check parameter count and write usage instruction
if (( $# != 3 )); then
  echo "Usage: $0 alignment reverse_alignment reference_path"
  exit 1
fi

reference_path=$3
reference_lines=`cat $3 | wc -l`

alignment_path=$1
alignment_reverse_path=$2
alignment_name=${1##*/}
alignment_reverse_name=${2##*/}
alignment_prefix=${alignment_name%.*}


# only use test data
tail -n $reference_lines $alignment_path > test.${alignment_name}
tail -n $reference_lines $alignment_reverse_path > test.${alignment_reverse_name}

# Do not reverse the alignment there
for method in "grow-diagonal-final" "grow-diagonal" "intersection" "union"; do
  ${SCRIPT_DIR}/combine_bidirectional_alignments.py test.${alignment_name}  test.${alignment_reverse_name} --method $method $4 > test.${alignment_prefix}.${method}.talp
done

for file_path in test.${alignment_prefix}*.talp test.${alignment_reverse_name}; do
  reverseRef=""
  if [[ ${file_path} == test.${alignment_reverse_name} ]]; then
    reverseRef="--reverseRef"
  fi
  ${SCRIPT_DIR}/aer.py ${reference_path} ${file_path} --oneRef $reverseRef --fAlpha 0.5
done

