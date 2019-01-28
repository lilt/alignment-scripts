#!/usr/bin/env python3

import argparse

# changing is not enough to change the language pairs, sorry
LANGUAGES = {"src", "tgt"}

def parse_args():
    """ parse arguments and return them """
    parser = argparse.ArgumentParser("Remove test sentences from train data (based on exact matches of either source OR target sentence)")
    parser.add_argument("train", help="Prefix of train data; train + {src, tgt} should be valid file paths")
    parser.add_argument("test", help="Prefix of test data; test + {src, tgt} should be valid file paths")
    parser.add_argument("output", help="Output prefix, output will be written to output + {src, tgt}")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    
    test_sentences = {}
    for ln in LANGUAGES:
        with open(args.test + "." + ln, "r") as f:
            test_sentences[ln] = {l for l in f.readlines()}

    with open(args.train + ".src", "r") as fi_src, open(args.output + ".src", "w") as fo_src, open(args.train + ".tgt", "r") as fi_tgt, open(args.output + ".tgt", "w") as fo_tgt:
        for line_src, line_tgt in zip(fi_src, fi_tgt):
            if line_src in test_sentences["src"] and line_tgt in test_sentences["tgt"]:
                print(line_src + "|||" + line_tgt, end="")
            else:
                fo_src.write(line_src)
                fo_tgt.write(line_tgt)

