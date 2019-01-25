#!/bin/bash

set -ex

PREPROCESS_DIR=${0%/run.sh}

${PREPROCESS_DIR}/train.sh
${PREPROCESS_DIR}/test.sh


for ln_pair in "roen" "enfr"; do
  for suffix in "src" "tgt"; do
    cat train/${ln_pair}.lc.${suffix} test/${ln_pair}.lc.${suffix} > train/${ln_pair}.lc.plustest.${suffix}
      spm_train --input_sentence_size      100000000 \
                --model_prefix             train/bpe.${ln_pair}.${suffix} \
                --model_type               bpe \
                --num_threads              4 \
                --split_by_unicode_script  1 \
                --split_by_whitespace      1 \
                --remove_extra_whitespaces 1 \
                --add_dummy_prefix         0 \
                --normalization_rule_name  identity \
                --vocab_size               10000 \
                --character_coverage       1.0 \
                --input                    train/${ln_pair}.lc.plustest.${suffix}
    spm_encode --model train/bpe.${ln_pair}.${suffix}.model < train/${ln_pair}.lc.${suffix} > train/${ln_pair}.lc.${suffix}.bpe
    spm_encode --model train/bpe.${ln_pair}.${suffix}.model < train/${ln_pair}.lc.plustest.${suffix} > train/${ln_pair}.lc.plustest.${suffix}.bpe
    spm_encode --model train/bpe.${ln_pair}.${suffix}.model < test/${ln_pair}.lc.${suffix} > test/${ln_pair}.lc.${suffix}.bpe
  done
done
 
