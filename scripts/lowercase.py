#!/usr/bin/env python3

import fileinput

for line in fileinput.input():
    print(line.lower(), end="")

