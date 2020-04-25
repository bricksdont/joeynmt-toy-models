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
    parser.add_argument("--seed", type=int, help="Random seed", required=False, default=13)

    args = parser.parse_args()

    return args


def read_connl_lines(handle):

    current_words = []

    for word in handle:

        if word == "\n":
            yield current_words
            current_words = []
        else:
            current_words.append(word)


def write_conll_line(line, handle):
    for word in line:
        handle.write(word)
    handle.write("\n")


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    random.seed(args.seed)

    num_lines = sum(1 for _ in open(args.src_input, "r"))
    assert num_lines >= args.size

    random_indexes = random.sample(range(num_lines), args.size)

    with open(args.src_input, "r") as src_input_handle, open(args.src_output, "w") as src_output_handle:
        src_lines = src_input_handle.readlines()

        for random_index in random_indexes:
            src_line = src_lines[random_index]
            src_output_handle.write(src_line)

    with open(args.trg_input, "r") as trg_input_handle, open(args.trg_output, "w") as trg_output_handle:
        trg_lines = trg_input_handle.readlines()

        for random_index in random_indexes:
            trg_line = trg_lines[random_index]
            trg_output_handle.write(trg_line)

    with open(args.conll_input, "r") as conll_input_handle, open(args.conll_output, "w") as conll_output_handle:

        conll_lines = list(read_connl_lines(conll_input_handle))

        for random_index in random_indexes:
            conll_line = conll_lines[random_index]
            write_conll_line(conll_line, conll_output_handle)


if __name__ == '__main__':
    main()
