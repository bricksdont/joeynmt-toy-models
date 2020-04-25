#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data

mkdir -p $data

# training data (includes syntactic parses for lemma factors on the source side)

if [[ ! -d $data/data.statmt.org ]]; then
  # ignoring robots.txt - which you should not do in general :-)
  wget -r --no-parent --reject "index.html*" -e robots=off http://data.statmt.org/rsennrich/wmt16_factors/de-en/ -P $data
fi

if [[ -f $data/data.statmt.org/rsennrich/wmt16_factors/de-en/newstest2013.conll.de.gz ]]; then
  (cd $data/data.statmt.org/rsennrich/wmt16_factors/de-en && gunzip *)

  rm $data/data.statmt.org/rsennrich/wmt16_factors/de-en/*synthetic*
fi

# complicated way of subsampling and shuffling, because parses are one word per line

train_size=10000

if [[ ! -f $data/train.tokenized.de ]]; then
  python $scripts/special_subsample.py --src-input $data/data.statmt.org/rsennrich/wmt16_factors/de-en/corpus.parallel.tok.de \
      --conll-input $data/data.statmt.org/rsennrich/wmt16_factors/de-en/corpus.parallel.conll.de \
      --trg-input $data/data.statmt.org/rsennrich/wmt16_factors/de-en/corpus.parallel.tok.en \
      --src-output $data/train.tokenized.de \
      --conll-output $data/train.conll.de \
      --trg-output $data/train.tokenized.en \
      --size $train_size
fi

# development and test data (preprocessed already up to truecasing)

wget http://data.statmt.org/wmt17/translation-task/preprocessed/de-en/dev.tgz -P $data

tar -xzvf $data/dev.tgz -C $data/dev

cp $data/dev/newstest2015.tc.de $data/dev.truecased.de
cp $data/dev/newstest2015.tc.en $data/dev.truecased.en
cp $data/data.statmt.org/rsennrich/wmt16_factors/de-en/newstest2015.conll.de $data/dev.conll.de

cp $data/dev/newstest2016.tc.de $data/test.truecased.de
cp $data/dev/newstest2016.tc.en $data/test.truecased.en
cp $data/data.statmt.org/rsennrich/wmt16_factors/de-en/newstest2016.conll.de $data/test.conll.de

# sizes
echo "Sizes of corpora:"
for corpus in train dev test; do
	echo "corpus: "$corpus
	wc -l $data/$corpus.*
done

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
