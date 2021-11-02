#!/bin/bash

# check parameter count and write usage instruction
if (( $# != 3 )); then
  echo "Usage: $0 source_path target_path output_path"
  exit 1
fi

# paste with tab as delimiter | remove empty source or target lines
paste $1 $2 | sed -E 's/\t/ ||| /g' | sed -e '/^ |||/d' -e '/||| $/d' > ${3}

