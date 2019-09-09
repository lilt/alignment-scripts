#!/bin/bash

set -ex

bpe=""
if (( $# == 1 )); then
  if [ "$1" != "bpe" ]; then
    echo "Use BPE as the first argument if you want to run fastalign using BPE tokenization"
    exit 1
  fi
  bpe=".bpe"
  echo "Using BPE"
fi

BASE_DIR=${PWD}

cd giza-forcealign

for ln_pair_name in "roen" "deen" "enfr"; do
  ln_pair=${ln_pair_name}${bpe}
  # Setup folder and create links for test data
  test_src="${BASE_DIR}/test/${ln_pair_name}.lc.src${bpe}"
  test_tgt="${BASE_DIR}/test/${ln_pair_name}.lc.tgt${bpe}"
  mkdir -p ${ln_pair}/Forward-ForceAlign ${ln_pair}/Backward-ForceAlign
  if [ ! -f ${ln_pair}/Forward-ForceAlign/test.lc.src ]; then
    ln -s ${test_src} ${ln_pair}/Forward-ForceAlign/test.lc.src
    ln -s ${test_tgt} ${ln_pair}/Forward-ForceAlign/test.lc.tgt
    ln -s ${test_src} ${ln_pair}/Backward-ForceAlign/test.lc.tgt
    ln -s ${test_tgt} ${ln_pair}/Backward-ForceAlign/test.lc.src
  fi
  # Run Forced Alignments 
  for direction in "Forward" "Backward"; do
    cd ${ln_pair}/${direction}-ForceAlign
    ${MGIZA_DIR}/mgizapp/scripts/plain2snt-hasvcb.py ../${direction}/*tst.src.vcb ../${direction}/*tst.trg.vcb test.lc.src test.lc.tgt test.snt otherdirection.snt src.vcbx tgt.vcbx
    ${MGIZA_DIR}/mgizapp/bin/snt2cooc test.cooc src.vcbx tgt.vcbx test.snt  # not sure if we need that step for bpe?

    if (( $# == 1 )); then
      # We can use the cooccurrence of the train data for bpe because we don't have any OOVs
      cooc_string=""
    else
      cooc_string="-coocurrence test.cooc"
    fi

    ${MGIZA_DIR}/mgizapp/bin/mgiza ../${direction}/*.gizacfg -o forcy -c test.snt -s src.vcbx -t tgt.vcbx ${cooc_string} -m1 0 -m2 0 -m3 0 -m4 3 -mh 0 -restart 11 -previoust ../${direction}/*.t3.final -previousa ../${direction}/*a3.final -previousd ../${direction}/*d3.final -previousn ../${direction}/*.n3.final -previousd4 ../${direction}/*.d4.final -previousd42 ../${direction}/*D4.final -previoushmm ../${direction}/*hhmm.5 -ncpus 1 -p0 0.975
    ${BASE_DIR}/scripts/a3ToTalp.py < forcy.A3.final.part* > test.talp
    cd -
  done
  # Score
  cd ${ln_pair}

  if (( $# == 1 )); then
    ${BASE_DIR}/scripts/sentencepiece_to_word_alignments.py ${test_src} ${test_tgt} < Forward-ForceAlign/test.talp > ${ln_pair}.test.talp
    ${BASE_DIR}/scripts/sentencepiece_to_word_alignments.py ${test_tgt} ${test_src} < Backward-ForceAlign/test.talp > ${ln_pair}.reverse.test.talp
  else
    cp Forward-ForceAlign/test.talp ${ln_pair}.test.talp
    cp Backward-ForceAlign/test.talp ${ln_pair}.reverse.test.talp
  fi
  ${BASE_DIR}/scripts/combine.sh ${ln_pair}.test.talp ${ln_pair}.reverse.test.talp ${BASE_DIR}/test/${ln_pair_name}.talp > ${ln_pair}-results.txt
  cd -
done

