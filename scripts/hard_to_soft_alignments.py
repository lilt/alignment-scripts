#!/usr/bin/env python3

import argparse

def parse_args():
    parser = argparse.ArgumentParser("Converts hard alignment (talp) to soft alignment (nematus)")
    parser.add_argument("alignment", help="path to alignment file (talp)")
    parser.add_argument("source", help="source file")
    parser.add_argument("target", help="target file")

    parser.add_argument("--oneIndexed", help="alignment indices start with 1", action='store_true')
    return parser.parse_args()

def read_file(path):
    result = []
    with open(path, "r") as f:
        for line in f:
            result.append(line.strip())
    return result

def read_hard_alignment(path, one_indexed=False):
    result = []
    with open(path, "r") as f:
        for line in f:
            line = line.replace("p", "-")
            result.append(set())
            for al in line.split():
                a, b = al.split("-")
                a, b = int(a), int(b)
                if one_indexed:
                    a = a - 1
                    b = b - 1
                result[-1].add((a, b)) 
    return result

if __name__ == "__main__":
    args = parse_args()
    source_sentences = read_file(args.source)
    target_sentences = read_file(args.target)

    hard_alignment = read_hard_alignment(args.alignment, args.oneIndexed)

    assert len(source_sentences) == len(target_sentences) 
    assert len(source_sentences) == len(hard_alignment)

    for i, (source, target, alignment) in enumerate(zip(source_sentences, target_sentences, hard_alignment)):
        source_len, target_len = len(source.split()), len(target.split())
        if source_len == 0 or target_len == 0:
            continue
        # we do not have a score, so set it to 0.0
        score = 0.0
        header = "{} ||| {} ||| {} ||| {} ||| {} {}".format(i, target, score,
                                                          source, source_len, target_len)
        print(header)
         
        # +1 because of <EOS> in source and target
        for tgt_id in range(target_len+1):
            # 0.0 or 1.0 if (s,t) present in hardalignment (casting fun :))
            line = [str(float((src_id, tgt_id) in alignment)) for src_id in range(source_len + 1)]
            print(" ".join(line))
        print()
        
