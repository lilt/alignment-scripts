#!/bin/bash

set -ex

export LC_ALL=en_US.UTF-8

PREPROCESS_DIR=${0%/run.sh}

${PREPROCESS_DIR}/test.sh
${PREPROCESS_DIR}/train.sh


for ln_pair in "roen" "enfr" "deen"; do
  for suffix in "src" "tgt"; do
    cat train/${ln_pair}.lc.${suffix} test/${ln_pair}.lc.${suffix} > train/${ln_pair}.lc.plustest.${suffix}
  done

  # only use sentencepiece if it is installed
  if command -v spm_train; then
    cat train/${ln_pair}.lc.plustest.src train/${ln_pair}.lc.plustest.tgt > train/${ln_pair}.lc.plustest.joint
    spm_train --input_sentence_size      100000000 \
              --model_prefix             train/bpe.${ln_pair} \
              --model_type               bpe \
              --num_threads              4 \
              --split_by_unicode_script  1 \
              --split_by_whitespace      1 \
              --remove_extra_whitespaces 1 \
              --normalization_rule_name  identity \
              --vocab_size               40000 \
              --character_coverage       1.0 \
              --add_dummy_prefix         1 \
              --input                    train/${ln_pair}.lc.plustest.joint

    for suffix in "src" "tgt"; do
      spm_encode --model train/bpe.${ln_pair}.model < train/${ln_pair}.lc.${suffix} > train/${ln_pair}.lc.${suffix}.bpe &
      spm_encode --model train/bpe.${ln_pair}.model < train/${ln_pair}.lc.plustest.${suffix} > train/${ln_pair}.lc.plustest.${suffix}.bpe &
      for dataset in "" ".trial" ".2repeat"; do
        spm_encode --model train/bpe.${ln_pair}.model < test/${ln_pair}${dataset}.lc.${suffix} > test/${ln_pair}${dataset}.lc.${suffix}.bpe &
      done
    done
  fi

done

wait
 
