#!/usr/bin/env python3

import argparse
import itertools

NEIGHBORING = {(-1, 0), (0, -1), (1, 0), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)}
METHODS = {"grow-diagonal-final", "grow-diagonal", "intersection", "union"}


def parse_args():
    """ parse arguments and return them """
    parser = argparse.ArgumentParser("Combine bidirectional alignments (e.g. en->de and de->en)")
    parser.add_argument("alignment", help="Path to alignment in talp format")
    parser.add_argument("alignment_reverse", help="Path to alignment in reverse direction in talp format")
    parser.add_argument("--method", default="grow-diagonal-final",
                        help="Method to combine alignments ({})".format(", ".join(METHODS)))
    parser.add_argument("--dont_reverse", action='store_true', help="Do not reverse alignment_reverse file (useful when using fastalign's -r option)")

    return parser.parse_args()


def get_length(align_union):
    """ Estimate length of source and target segment """
    max_e = max((e for e, f in align_union))
    max_f = max((f for e, f in align_union))
    return max_e + 1, max_f + 1


def grow_diag_final(e2f, f2e, finalize=True):
    """ Implemented as in http://www.statmt.org/moses/?n=FactoredTraining.AlignWords """
    alignments = e2f.intersection(f2e)
    alignment_union = e2f.union(f2e)

    e_len, f_len = get_length(alignment_union)
    alignments = grow_diag(alignments, alignment_union, e_len, f_len)
    if finalize:
        alignments = final(alignments, e2f, e_len, f_len)
        alignments = final(alignments, f2e, e_len, f_len)

    return alignments


def grow_diag(alignments, alignment_union, e_len, f_len):
    """ Adds alignment in the neighborhood of alignments in the intersection """
    finished = False

    while not finished:
        finished = True

        for e, f in itertools.product(range(e_len), range(f_len)):
            if (e, f) in alignments:
                for e_new, f_new in ((e + e_delta, f + f_delta) for e_delta, f_delta in NEIGHBORING):
                    if e_new not in {e for e, f in alignments} and f_new not in {f for e, f in alignments} \
                            and (e_new, f_new) in alignment_union:
                        alignments.add((e_new, f_new))
                        finished = False

    return alignments


def final(alignments, directional_alignment, e_len, f_len):
    """ Adds alignments from directional alignment when word is not a valid alignment yet """
    for e_new, f_new in itertools.product(range(e_len), range(f_len)):
        if e_new not in {e for e, f in alignments} and f_new not in {f for e, f in alignments} \
                and (e_new, f_new) in directional_alignment:
            alignments.add((e_new, f_new))
    return alignments


def parse_single_alignment(string, reverse=False, one_indexed=False):
    """
    Parses a single alignment point
    :param string: String representing a single alignment point, e.g. '1-42'
    :param reverse: if to reverse the alignments from src-tgt to tgt-src
    :param one_indexed: if the position of first word in a sentence is indexed with 1 (or 0)
    :return: returns the alignment as a tuple of integers, e.g. (1, 42)
    """

    assert ('-' in string or 'p' in string) and 'Bad alignment separator'

    src_pos, tgt_pos = string.replace('p', '-').split('-')
    src_pos, tgt_pos = int(src_pos), int(tgt_pos)

    if one_indexed:
        src_pos -= 1
        tgt_pos -= 1

    if reverse:
        src_pos, tgt_pos = tgt_pos, src_pos

    return src_pos, tgt_pos


def parse_line(l, reverse=False):
    alignments = set()
    for s in l.split():
        alignments.add(parse_single_alignment(s, reverse))
    return alignments


if __name__ == "__main__":
    ARGS = parse_args()
    assert ARGS.method in METHODS and "Specified method not implemented"

    with open(ARGS.alignment, 'r') as f1:
        with open(ARGS.alignment_reverse, 'r') as f2:
            for l1, l2 in zip(f1, f2):
                al1 = parse_line(l1)
                al2 = parse_line(l2, reverse=(not ARGS.dont_reverse))

                al_combined = None
                if ARGS.method == "grow-diagonal-final":
                    al_combined = grow_diag_final(al1, al2)
                if ARGS.method == "grow-diagonal":
                    al_combined = grow_diag_final(al1, al2, finalize=False)
                elif ARGS.method == "intersection":
                    al_combined = al1.intersection(al2)
                elif ARGS.method == "union":
                    al_combined = al1.union(al2)

                for a, b in al_combined:
                    print("{}-{}".format(a, b), end=" ")
                print()
