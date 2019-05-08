#!/usr/bin/env python3

import argparse
import itertools


def parse_args():
    parser = argparse.ArgumentParser("Converts subword alignments in talp format to alignments between words.")
    parser.add_argument("subword_alignments", help="Path to subwords alignment in talp format, e.g. '10-9' (these must be zero indexed, the alignment between the first word of the source and the target is 0-0, all alignments are treated as sure alignments)")
    parser.add_argument("spm_source", help="Textfile containing source sentences tokenized with sentencepiece")
    parser.add_argument("spm_target", help="Textfile containing target sentences tokenized with sentencepiece")

    return parser.parse_args()


def get_mapping(subword_sequence):
    """ Creates a mapping from subword to word indices
    >>> get_mapping("S olved ▁tickets ▁and ▁re op ens")
    [0, 0, 1, 2, 3, 3, 3]
    """
    return list(itertools.accumulate([int('▁' in x) for x in subword_sequence.split()]))

def parse_single_alignment(string, reverse=False, one_indexed=False):
    assert ('-' in string or 'p' in string) and 'Bad Alignment separator'

    a, b = string.replace('p', '-').split('-')
    a, b = int(a), int(b)

    if one_indexed:
        a = a - 1
        b = b - 1

    if reverse:
        a, b = b, a

    return a, b


if __name__ == "__main__":
    args = parse_args()

    f_a, f_s, f_t = map(open, [args.subword_alignments, args.spm_source, args.spm_target])
    for alignment_string, source_string, target_string in zip(f_a, f_s, f_t):
        subword_alignments = {parse_single_alignment(a) for a in alignment_string.split()}
        map_src, map_tgt = map(get_mapping, [source_string, target_string])
        word_alignments = {"{}-{}".format(map_src[s], map_tgt[t]) for s, t in subword_alignments}
        print(" ".join(word_alignments))

