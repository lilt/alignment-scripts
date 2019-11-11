#!/usr/bin/env python3

import sys
import itertools
import fileinput

def get_mapping(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        for l in f:
            subwords = l.strip().split()  
            yield list(itertools.accumulate([int('▁' in x) for x in subwords]))

def convert(src_file, tgt_file):
    examples = zip(get_mapping(src_file), get_mapping(tgt_file), fileinput.input(files=["-"]))
    for src_map, tgt_map, line in examples:
        subword_alignments = {(int(a), int(b)) for a, b in (x.split("-") for x in line.split())}
        # Subtract 1 to ensure zero indexed alignments (Using --add_dummy_prefix 1 for spm temporarly changed that)
        word_alignments = {"{}-{}".format(src_map[a] - 1, tgt_map[b] - 1) for a, b in subword_alignments}
        yield word_alignments


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Two parameters are required, e.g.: {} text.spm.source text.spm.target < sentence_piece.talp > word.talp".format(sys.argv[0]))
        exit(1)
    for word_alignment in convert(*sys.argv[1:]):
        print(" ".join(word_alignment))

