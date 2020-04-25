#! /usr/bin/python3

import random
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--src-input", type=str, help="Source lines input", required=True)
    parser.add_argument("--conll-input", type=str, help="Source conll lines input", required=True)
    parser.add_argument("--trg-input", type=str, help="Target lines input", required=True)

    parser.add_argument("--src-output", type=str, help="Source lines output", required=True)
    parser.add_argument("--conll-output", type=str, help="Source conll lines output", required=True)
    parser.add_argument("--trg-output", type=str, help="Target lines output", required=True)

    parser.add_argument("--size", type=int, help="Subsample to this many lines", required=True)

    args = parser.parse_args()

    return args


def read_connl(handle):

    lines = []

    current_words = []

    for word in handle:

        if word == "\n":
            lines.append(current_words)
            current_words = []
        else:
            current_words.append(word)

    return lines


def write_conll(lines, handle):

    for line in lines:
        for word in line:
            handle.write(word)
        handle.write("\n")


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    with open(args.conll_input, "r") as conll_handle:
        conll_lines = read_connl(conll_handle)

    src_lines = open(args.src_input, "r").readlines()
    trg_lines = open(args.src_input, "r").readlines()

    num_lines = len(src_lines)
    assert num_lines >= args.size

    random_indexes = random.sample(range(num_lines), args.size)

    with open(args.src_output, "w") as src_handle, open(args.conll_output, "w") as conll_handle, \
         open(args.trg_output, "w") as trg_handle:

        for random_index in random_indexes:

            src_line = src_lines[random_index]
            trg_line = trg_lines[random_index]
            conll_line = conll_lines[random_index]

            src_handle.write(src_line)
            trg_handle.write(trg_line)
            write_conll(conll_line, conll_handle)


if __name__ == '__main__':
    main()
