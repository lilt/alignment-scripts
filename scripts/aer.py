#!/usr/bin/env python3

import argparse
import itertools
from collections import Counter


def parse_args():
    parser = argparse.ArgumentParser("Calculates Alignment Error Rate, output format: AER (Precision, Recall, Alginment-Links-Hypothesis)")
    parser.add_argument("reference", help="path of reference alignment, e.g. '10-9 11p42'")
    parser.add_argument("hypothesis", help="path to hypothesis alignment")

    parser.add_argument("--reverseRef", help="reverse reference alignment", action='store_true')
    parser.add_argument("--reverseHyp", help="reverse hypothesis alignment", action='store_true')

    parser.add_argument("--oneRef", help="reference indices start at index 1", action='store_true')
    parser.add_argument("--oneHyp", help="hypothesis indices start at index 1", action='store_true')

    parser.add_argument("--source", default="", help="the source sentence, used for an error analysis")
    parser.add_argument("--target", default="", help="the target sentence, used for an error analysis")
    parser.add_argument("--most_common_errors", default=10, type=int)

    return parser.parse_args()


def calculate_metrics(array_sure, array_possible, array_hypothesis, source_sentences=(), target_sentences=()):
    """ Calculates precision, recall and alignment error rate as described in "A Systematic Comparison of Various
        Statistical Alignment Models" (https://www.aclweb.org/anthology/J/J03/J03-1002.pdf) in chapter 5


    Args:
        array_sure: array of sure alignment links
        array_possible: array of possible alignment links
        array_hypothesis: array of hypothesis alignment links
    """

    number_of_sentences = len(array_sure)
    assert number_of_sentences == len(array_possible)
    assert number_of_sentences == len(array_hypothesis)

    errors = Counter()

    sum_a_intersect_p, sum_a_intersect_s, sum_s, sum_a = 0.0, 0.0, 0.0, 0.0
    for S, P, A, source, target in itertools.zip_longest(array_sure, array_possible, array_hypothesis, source_sentences, target_sentences):
        sum_a += len(A)
        sum_s += len(S)
        sum_a_intersect_p += len(A.intersection(P))
        sum_a_intersect_s += len(A.intersection(S))
        for src_pos, tgt_pos in A:
            if source and target and (src_pos, tgt_pos) not in P:
                if source[src_pos] == "," and target[tgt_pos] == "," and False:
                    print(source, target)
                errors[source[src_pos], target[tgt_pos]] += 1

    precision = sum_a_intersect_p / sum_a
    recall = sum_a_intersect_s / sum_s
    aer = 1.0 - ((sum_a_intersect_p + sum_a_intersect_s) / (sum_a + sum_s))
    
    return precision, recall, aer, errors


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

def read_text(path):
    if path == "":
        return []
    with open(path, "r", encoding="utf-8") as f:
        return [l.split() for l in f]

if __name__ == "__main__":
    args = parse_args()
    sure, possible, hypothesis = [], [], []

    source, target = map(read_text, [args.source, args.target])

    with open(args.reference, 'r') as f:
        for line in f:
            sure.append(set())
            possible.append(set())

            for alignment_string in line.split():

                sure_alignment = True if '-' in alignment_string else False
                alignment_tuple = parse_single_alignment(alignment_string, args.reverseRef, args.oneRef)

                if sure_alignment:
                    sure[-1].add(alignment_tuple)
                possible[-1].add(alignment_tuple)

    with open(args.hypothesis, 'r') as f:
        for line in f:
            hypothesis.append(set())

            for alignment_string in line.split():
                alignment_tuple = parse_single_alignment(alignment_string, args.reverseHyp, args.oneHyp)
                hypothesis[-1].add(alignment_tuple)

    precision, recall, aer, errors = calculate_metrics(sure, possible, hypothesis, source, target)
    print("{0}: {1:.1f}% ({2:.1f}%/{3:.1f}%/{4})".format(args.hypothesis,
        aer * 100.0, precision * 100.0, recall * 100.0, sum([len(x) for x in hypothesis])))

    if args.source:
        assert args.target and args.most_common_errors > 0, "To output the most common errors, define a source and target file and the number of errors to output"
        print(errors.most_common(args.most_common_errors))
 
