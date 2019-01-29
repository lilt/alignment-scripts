#!/usr/bin/env python3

import argparse


def parse_args():
    parser = argparse.ArgumentParser("Calculates Alignment Error Rate")
    parser.add_argument("reference", help="path of reference alignment, e.g. '10-9 11p42'")
    parser.add_argument("hypothesis", help="path to hypothesis alignment")

    parser.add_argument("--reverseRef", help="reverse reference alignment", action='store_true')
    parser.add_argument("--reverseHyp", help="reverse hypothesis alignment", action='store_true')

    parser.add_argument("--oneRef", help="reference indices start at index 1", action='store_true')
    parser.add_argument("--oneHyp", help="hypothesis indices start at index 1", action='store_true')

    return parser.parse_args()


def calculate_metrics(array_sure, array_possible, array_hypothesis):
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

    sum_a_intersect_p, sum_a_intersect_s, sum_s, sum_a = 0.0, 0.0, 0.0, 0.0
    for S, P, A in zip(array_sure, array_possible, array_hypothesis):
        sum_a += len(A)
        sum_s += len(S)
        sum_a_intersect_p += len(A.intersection(P))
        sum_a_intersect_s += len(A.intersection(S))

    precision = sum_a_intersect_p / sum_a
    recall = sum_a_intersect_s / sum_s
    aer = 1.0 - ((sum_a_intersect_p + sum_a_intersect_s) / (sum_a + sum_s))
    
    return precision, recall, aer


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
    sure, possible, hypothesis = [], [], []

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

    precision, recall, aer = calculate_metrics(sure, possible, hypothesis)
    print("{0} ({1}): {2:.1f}% ({3:.1f}%/{4:.1f}%) AER (Precision/Recall)".format(args.hypothesis, args.reference,
        aer * 100.0, precision * 100.0, recall * 100.0))
