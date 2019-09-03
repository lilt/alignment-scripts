#!/bin/bash

set -ex

BASE_DIR=${PWD}

mkdir -p giza-forcealign
cd giza-forcealign

for ln_pair in "deen" "enfr" "roen"; do
  # Setup folder and create links for test data
  mkdir -p ${ln_pair}/Forward-ForceAlign ${ln_pair}/Backward-ForceAlign
  if [ ! -f ${ln_pair}/Forward-ForceAlign/test.lc.src ]; then
    ln -s ${BASE_DIR}/test/${ln_pair}.lc.src ${ln_pair}/Forward-ForceAlign/test.lc.src
    ln -s ${BASE_DIR}/test/${ln_pair}.lc.tgt ${ln_pair}/Forward-ForceAlign/test.lc.tgt
    ln -s ${BASE_DIR}/test/${ln_pair}.lc.src ${ln_pair}/Backward-ForceAlign/test.lc.tgt
    ln -s ${BASE_DIR}/test/${ln_pair}.lc.tgt ${ln_pair}/Backward-ForceAlign/test.lc.src
  fi
  # Run Forced Alignments 
  for direction in "Forward" "Backward"; do
    cd ${ln_pair}/${direction}-ForceAlign
    ${MGIZA_DIR}/mgizapp/scripts/plain2snt-hasvcb.py ../${direction}/*tst.src.vcb ../${direction}/*tst.trg.vcb test.lc.src test.lc.tgt test.snt otherdirection.snt src.vcbx tgt.vcbx
    ${MGIZA_DIR}/mgizapp/bin/snt2cooc test.cooc src.vcbx tgt.vcbx test.snt
    ${MGIZA_DIR}/mgizapp/bin/mgiza ../${direction}/*.gizacfg -o forcy -c test.snt -coocurrence test.cooc -s src.vcbx -t tgt.vcbx -m1 0 -m2 0 -m3 0 -m4 5 -mh 0 -restart 11 -previoust ../${direction}/*.t3.final -previousa ../${direction}/*a3.final -previousd ../${direction}/*d3.final -previousn ../${direction}/*.n3.final -previousd4 ../${direction}/*.d4.final -previousd42 ../${direction}/*D4.final -previoushmm ../${direction}/*hhmm.5 -ncpus 1
    ${BASE_DIR}/scripts/a3ToTalp.py < forcy.A3.final.part* > test.talp
    cd -
  done
  # Score
  cd ${ln_pair}
  cp Forward-ForceAlign/test.talp ${ln_pair}.test.talp
  cp Backward-ForceAlign/test.talp ${ln_pair}.reverse.test.talp
  ${BASE_DIR}/scripts/combine.sh ${ln_pair}.test.talp ${ln_pair}.reverse.test.talp ${BASE_DIR}/test/${ln_pair}.talp > ${ln_pair}-results.txt
  cd -
done

