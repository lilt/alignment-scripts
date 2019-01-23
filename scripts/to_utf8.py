#!/usr/bin/env python3

import argparse


def parse_args():
    parser = argparse.ArgumentParser("removes unconform utf-8 lines")
    parser.add_argument("source", help="path of source file")
    parser.add_argument("target", help="path of target file")
    parser.add_argument("output_postfix", help="output postfix of the generated files")
    parser.add_argument("--encoding", default="utf-8", help="encoding of the input files")
    parser.add_argument("--lowercase", help="if to lowercase the input", action='store_true')

    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()

    invalid_lines = 0
    with open(args.source, 'rb') as source_handle, open(args.target, 'rb') as target_handle, open(args.source + "." + args.output_postfix, "w") as source_output_handle, open(args.target + "." + args.output_postfix, "w") as target_output_handle:
        for src, tgt in zip(source_handle, target_handle):
            try:
                src_unicode = src.decode(args.encoding)
                tgt_unicode = tgt.decode(args.encoding)
                if args.lowercase:
                    src_unicode = src_unicode.lower()
                    tgt_unicode = tgt_unicode.lower()
                source_output_handle.write(src_unicode)
                target_output_handle.write(tgt_unicode)
            except Exception as e:
                invalid_lines += 1
                print(str(e))

    print("Number of invalid lines: {}".format(invalid_lines))
 
