#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$(realpath $base/data)
shared_models=$base/shared_models
tools=$base/tools

mkdir -p $shared_models

src=de
trg=it

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

word_vocab_size_per_language=1000
bpe_num_operations_1=2000
bpe_num_operations_2=4000
bpe_vocab_threshold=10

# subsample train to 100k

head -n 100000 $data/train.$src-$trg.$src > $data/train.$src
head -n 100000 $data/train.$src-$trg.$trg > $data/train.$trg

# link dev and test files

ln -snf $data/valid.$src-$trg.$src $data/dev.$src
ln -snf $data/valid.$src-$trg.$trg $data/dev.$trg

ln -snf $data/test.$src-$trg.$src $data/test.$src
ln -snf $data/test.$src-$trg.$trg $data/test.$trg

# normalize train, dev and test

for corpus in train dev test; do
	cat $data/$corpus.$src | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/$corpus.normalized.$src
	cat $data/$corpus.$trg | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/$corpus.normalized.$trg
done

# tokenize train, dev and test

for corpus in train dev test; do
	cat $data/$corpus.normalized.$src | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $src > $data/$corpus.tokenized.$src
	cat $data/$corpus.normalized.$trg | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $trg > $data/$corpus.tokenized.$trg
done

# learn BPE model 1 on train (concatenate both languages)

subword-nmt learn-joint-bpe-and-vocab -i $data/train.tokenized.$src $data/train.tokenized.$trg \
	--write-vocabulary $shared_models/vocab.bpe1.$src $shared_models/vocab.bpe1.$trg \
	-s $bpe_num_operations_1 --total-symbols -o $shared_models/$src$trg.bpe1

# apply BPE model 1 to train, test and dev

for corpus in train dev test; do
	subword-nmt apply-bpe -c $shared_models/$src$trg.bpe1 --vocabulary $shared_models/vocab.bpe1.$src --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.tokenized.$src > $data/$corpus.bpe1.$src
	subword-nmt apply-bpe -c $shared_models/$src$trg.bpe1 --vocabulary $shared_models/vocab.bpe1.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.tokenized.$trg > $data/$corpus.bpe1.$trg
done

# learn BPE model 2 on train (concatenate both languages)

subword-nmt learn-joint-bpe-and-vocab -i $data/train.tokenized.$src $data/train.tokenized.$trg \
	--write-vocabulary $shared_models/vocab.bpe2.$src $shared_models/vocab.bpe2.$trg \
	-s $bpe_num_operations_2 --total-symbols -o $shared_models/$src$trg.bpe2

# apply BPE model 2 to train, test and dev

for corpus in train dev test; do
	subword-nmt apply-bpe -c $shared_models/$src$trg.bpe2 --vocabulary $shared_models/vocab.bpe2.$src --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.tokenized.$src > $data/$corpus.bpe2.$src
	subword-nmt apply-bpe -c $shared_models/$src$trg.bpe2 --vocabulary $shared_models/vocab.bpe2.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.tokenized.$trg > $data/$corpus.bpe2.$trg
done

# define BPE vocabularies

python $tools/joeynmt/scripts/build_vocab.py $data/train.bpe1.$src $data/train.bpe1.$trg --output_path $shared_models/vocab.joeynmt.bpe_2k

python $tools/joeynmt/scripts/build_vocab.py $data/train.bpe2.$src $data/train.bpe2.$trg --output_path $shared_models/vocab.joeynmt.bpe_4k

# file sizes
wc -l $data/*tokenized* $data/*bpe*
wc -l $shared_models/vocab.*

# sanity checks

echo "At this point, please check that 1) file sizes are as expected, 2) languages are correct and 3) material is still parallel"

