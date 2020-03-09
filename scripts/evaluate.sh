#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
translations=$base/translations

mkdir -p $translations

src=de
trg=en

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

model_name=model_wmt17
num_threads=6

##########################################

OMP_NUM_THREADS=$num_threads python -m sockeye.translate \
				-i $data/test.bpe.$src \
				-o $translations/test.bpe.$model_name.$trg \
				-m $base/models/$model_name \
				--beam-size 10 \
				--length-penalty-alpha 1.0 \
				--use-cpu \
				--batch-size 100

# undo BPE

cat $translations/test.bpe.$model_name.$trg | sed 's/\@\@ //g' > $translations/test.truecased.$model_name.$trg

# undo truecasing

cat $translations/test.truecased.$model_name.$trg | $MOSES/recaser/detruecase.perl > $translations/test.tokenized.$model_name.$trg

# undo tokenization

cat $translations/test.tokenized.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations/test.$model_name.$trg

# compute case-sensitive BLEU on detokenized data

cat $translations/test.$model_name.$trg | sacrebleu $data/test.$trg
		
