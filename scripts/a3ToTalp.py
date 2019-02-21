#!/usr/bin/env python3

import fileinput
import re

REGEX_ALIGNMENTS = re.compile(r'\({[^}]*}\)')
FAIL_STRING = "ASDFFDS42fsdafads"

def get_id(line):
    # line_id is enclosed in parenthesis
    # e.g.: Sentence pair (79) source length 12 target length 15 alignment score : 5.75958e-25
    start_pos = line.find("(") + 1
    end_pos = line.find(")")
    sentence_id = int(line[start_pos: end_pos])
    return sentence_id

def get_talp_string(line):
    alignments = set()
    for src_pos, tgt_al_group in enumerate(REGEX_ALIGNMENTS.finditer(line)):
        # we skip alignments to NULL
        if src_pos == 0:
            continue

        # [2:-2] removes ({ at the beginning and }) at the end of the string
        tgt_al_string = tgt_al_group.group()[2:-2]
        try:
            tgt_pos_set = {int(x) for x in tgt_al_string.split()}
        except:
            print(line)
            print(tgt_al_group.group())
            exit(1)
        for tgt_pos in tgt_pos_set:
            # make it 0 based instead of 1 based
            talp_string = "{}-{}".format(src_pos - 1, tgt_pos - 1)
            alignments.add(talp_string)

    return " ".join(alignments)

if __name__ == "__main__":

    alignments = {}
    lines = []
    skipped_max = 0
    error = False

    for line in fileinput.input(mode='rb'):

        try:
            line = line.decode("utf-8")
            lines.append(line)
        except UnicodeDecodeError:
            lines.append(FAIL_STRING)

        # 3 lines describe one sentence
        assert len(lines) <= 3 
        if len(lines) == 3:
            sentence_id = get_id(lines[0])
            if FAIL_STRING not in lines:
                talp_string = get_talp_string(lines[2])
                # mgiza produced multiple times the same sentence id
                alignments[sentence_id] = talp_string
            else:
                skipped_max = max(skipped_max, sentence_id)
            lines = []

    for sentence_id in sorted(alignments.keys()):
        print(alignments[sentence_id], flush=True)
#    print(skipped_max)

