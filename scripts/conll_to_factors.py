#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: Rico Sennrich, modified by Mathias Müller
# Distributed under MIT license

# this file is adapted from:
# https://raw.githubusercontent.com/rsennrich/wmt16-scripts/master/preprocess/conll_to_factors.py

# take conll file, and bpe-segmented text, and produce factored output

import sys
import re

from collections import namedtuple


Word = namedtuple(
    'Word',
    ['pos', 'word', 'lemma', 'tag', 'morph', 'head', 'func', 'proj_head', 'proj_func'])


def escape_special_chars(line):
    line = line.replace('\'', '&apos;')  # xml
    line = line.replace('"', '&quot;')  # xml
    line = line.replace('[', '&#91;')  # syntax non-terminal
    line = line.replace(']', '&#93;')  # syntax non-terminal
    line = line.replace('|', '&#124;')

    return line

def read_sentences(fobj):
    sentence = []

    for line in fobj:

        if line == "\n":
            yield sentence
            sentence = []
            continue

        try:
            (
                pos,
                word,
                lemma,
                tag,
                tag2,
                morph,
                head,
                func,
                proj_head,
                proj_func,
            ) = line.split()
        except ValueError:  # Word may be unicode whitespace.
            (
                pos,
                word,
                lemma,
                tag,
                tag2,
                morph,
                head,
                func,
                proj_head,
                proj_func,
            ) = re.split(' *\t*', line.strip())

        word = escape_special_chars(word)
        lemma = escape_special_chars(lemma)
        morph = morph.replace('|',',')

        if proj_head == '_':
            proj_head = head
            proj_func = func

        sentence.append(
            Word(
                int(pos), word, lemma, tag2, morph, int(head), func, int(proj_head),
                proj_func))


def get_factors(sentence, idx):

    try:
       word = sentence[idx]
    except IndexError:
       sys.stderr.write("sentence: %s, idx: %d" % (str(sentence), i))
       raise

    factors = [word.tag2]

    return factors

#text file that has been preprocessed and split with BPE
bpe_file = open(sys.argv[1])

#conll file with annotation of original corpus; mapping is done by index, so number of sentences and words (before BPE) must match
conll_file = open(sys.argv[2])
conll_sentences = read_sentences(conll_file)

for line in bpe_file:
  state = "O"
  i = 0
  sentence = next(conll_sentences)
  for word in line.split():
    factors = get_factors(sentence, i)
    if word.endswith('@@'):
        if state == "O" or state == "E":
            state = "B"
        elif state == "B" or state == "I":
            state = "I"
    else:
        i += 1
        if state == "B" or state == "I":
            state = "E"
        else:
            state = "O"
    sys.stdout.write(''.join([str(f) for f in factors]) + ' ')
  sys.stdout.write('\n')
