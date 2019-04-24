#!/usr/bin/env python3

import argparse

def parse_args():
    parser = argparse.ArgumentParser("Augment an alignment data set by repeating its sentences (Sentence: A B C -> A B C A B C)")
    parser.add_argument("source", help="Path of the source text")
    parser.add_argument("target", help="Path of the target text")
    parser.add_argument("alignment", help="Path of the gold alignments, format '10-9 11p42'")
    parser.add_argument("output_prefix", help="Prefix for output files, prefix + {.src, .tgt, .talp}")

    parser.add_argument("--repeats", default=2, type=int)
    parser.add_argument("--max_sentence_length", default=300, type=int)

    return parser.parse_args()

def read_text(path):
    with open(path, "r", encoding="utf-8") as f:
        # make sure we only use spaces as word separators
        return [" ".join(l.split()) for l in f]

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

def read_alignment(path):
    sure, possible = [], []
    with open(path, 'r') as f:
        for line in f:
            sure.append(set())
            possible.append(set())

            for alignment_string in line.split():

                sure_alignment = True if '-' in alignment_string else False
                alignment_tuple = parse_single_alignment(alignment_string)

                if sure_alignment:
                    sure[-1].add(alignment_tuple)
                else:
                    possible[-1].add(alignment_tuple)
    return sure, possible
 

if __name__ == "__main__":
    args = parse_args()

    source_list, target_list = map(read_text, [args.source, args.target])
    sure_list, possible_list = read_alignment(args.alignment)

    length = len(source_list)
    assert length == len(target_list)
    assert length == len(sure_list)
    assert length == len(possible_list)

    with open(args.output_prefix + ".src", "w") as src_fo, open(args.output_prefix + ".tgt", "w") as tgt_fo, open(args.output_prefix + ".talp", "w") as talp_fo:
        for source, target, sure, possible in zip(source_list, target_list, sure_list, possible_list):
            # Clip repeats such that neither source nor target will contain more than max_length words
            max_length = max(len(source.split()), len(target.split()))
            repeats = min(int(args.max_sentence_length/max_length), args.repeats)
           
            if repeats <= 0:
                print("Skipping the following sentence pair due to max length")
                print(source)
                print(target)
                print()
                continue

            new_sure, new_possible = set(), set()
            for i in range(repeats):
                offset_source = i * len(source.split())
                offset_target = i * len(target.split())
                new_sure |= {(x + offset_source, y + offset_target) for (x, y) in sure}
                new_possible |= {(x + offset_source, y + offset_target) for (x, y) in possible}
            alignments = ["{}-{}".format(x, y) for (x,y) in new_sure]            
            alignments.extend(["{}p{}".format(x, y) for (x,y) in new_possible])
            print(" ".join([source for _ in range(repeats)]), file=src_fo)
            print(" ".join([target for _ in range(repeats)]), file=tgt_fo)
            print(" ".join(alignments), file=talp_fo)

