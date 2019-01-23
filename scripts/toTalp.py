#!/usr/bin/env python3

import fileinput
from collections import defaultdict

# Converts Romanian-English and English-French reference file to talp format
alignment_dict = defaultdict(set)
for line in fileinput.input():
    line_number, source_id, target_id, label = line.split()
    source_id = int(source_id)
    target_id = int(target_id)
    assert label in {"S", "P"}
    separator = "-"
    if label == "P":
        separator = "p"
    alignment_string = "{}{}{}".format(source_id, separator, target_id)
    alignment_dict[int(line_number)].add(alignment_string)

for key in sorted(alignment_dict.keys()):
    al_set = alignment_dict[key]
    print(" ".join(al_set))

