#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
tools=$base/tools

mkdir -p $base/shared_models

src=de
trg=en

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$tools/moses-scripts/scripts

bpe_num_operations=2000
bpe_vocab_threshold=10

#################################################################

# measure time

SECONDS=0

# train set does need to be truecased: learn truecase model on train (learn one model for each language)

$MOSES/recaser/train-truecaser.perl -corpus $data/train.tokenized.$src -model $base/shared_models/truecase-model.$src
$MOSES/recaser/train-truecaser.perl -corpus $data/train.tokenized.$trg -model $base/shared_models/truecase-model.$trg

# dev and test input files are preprocessed already up to truecasing, but: tokenization needs to be identical to CONLL files, extract source from CONLL:

for corpus in dev test; do
  cut -f 2 $data/$corpus.conll.$src | \
    awk -v RS="" '{$1=$1}7' | \
    $MOSES/scripts/tokenizer/escape-special-chars.perl -l $src > $data/$corpus.tokenized.$src
done

# apply truecase model to train, test and dev

for corpus in train; do
	$MOSES/recaser/truecase.perl -model $base/shared_models/truecase-model.$src < $data/$corpus.tokenized.$src > $data/$corpus.truecased.$src
	$MOSES/recaser/truecase.perl -model $base/shared_models/truecase-model.$trg < $data/$corpus.tokenized.$trg > $data/$corpus.truecased.$trg
done

# apply truecase model to source side of dev and test

for corpus in dev test; do
	$MOSES/recaser/truecase.perl -model $base/shared_models/truecase-model.$src < $data/$corpus.tokenized.$src > $data/$corpus.truecased.$src
done

# remove preprocessing for target language test data, for evaluation

cat $data/test.truecased.$trg | $MOSES/recaser/detruecase.perl > $data/test.tokenized.$trg
cat $data/test.tokenized.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $data/test.$trg

# learn BPE model on train (concatenate both languages)

subword-nmt learn-joint-bpe-and-vocab -i $data/train.truecased.$src $data/train.truecased.$trg \
	--write-vocabulary $base/shared_models/vocab.$src $base/shared_models/vocab.$trg \
	-s $bpe_num_operations -o $base/shared_models/$src$trg.bpe

# apply BPE model to train, test and dev

for corpus in train dev test; do
	subword-nmt apply-bpe -c $base/shared_models/$src$trg.bpe --vocabulary $base/shared_models/vocab.$src --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.truecased.$src > $data/$corpus.bpe.$src
	subword-nmt apply-bpe -c $base/shared_models/$src$trg.bpe --vocabulary $base/shared_models/vocab.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.truecased.$trg > $data/$corpus.bpe.$trg
done

# generate factors for BPE versions of corpora

for corpus in train dev test; do
  python $scripts/conll_to_factors.py $data/$corpus.bpe.$src $data/$corpus.conll.$src > $data/$corpus.factor
done

# build joeynmt vocab

python $tools/joeynmt/scripts/build_vocab.py $data/train.bpe.$src $data/train.bpe.$trg --output_path $base/shared_models/vocab.txt

# build joeynmt factor vocab

python $tools/joeynmt/scripts/build_vocab.py $data/train.factor --output_path $base/shared_models/vocab.factor

# file sizes

for corpus in train dev test; do
	echo "corpus: "$corpus
	wc -l $data/$corpus.bpe.$src $data/$corpus.bpe.$trg $data/$corpus.factor
done

wc -l $base/shared_models/*

# sanity checks

echo "At this point, please check that 1) file sizes are as expected, 2) languages are correct and 3) material is still parallel"

echo "time taken:"
echo "$SECONDS seconds"
