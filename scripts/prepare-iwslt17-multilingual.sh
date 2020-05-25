#! /bin/bash

# This code is taken from:
# https://raw.githubusercontent.com/awslabs/sockeye/master/docs/tutorials/multilingual/prepare-iwslt17-multilingual.sh
# Original file: MIT licensed. "Copyright (c) Facebook, Inc. and its affiliates. All rights reserved."

LANGS=(
    "de"
    "it"
    "nl"
    "ro"
    "en"
)

ROOT=$(dirname "$0")/..

ORIG=$ROOT/iwslt17_orig
DATA=$ROOT/data
mkdir -p "$ORIG" "$DATA"

URLS=(
    "https://wit3.fbk.eu/archive/2017-01-trnmted/texts/DeEnItNlRo/DeEnItNlRo/DeEnItNlRo-DeEnItNlRo.tgz"
)
ARCHIVES=(
    "DeEnItNlRo-DeEnItNlRo.tgz"
)

UNARCHIVED_NAME="DeEnItNlRo-DeEnItNlRo"

# download and extract data
for ((i=0;i<${#URLS[@]};++i)); do
    ARCHIVE=$ORIG/${ARCHIVES[i]}
    if [ -f "$ARCHIVE" ]; then
        echo "$ARCHIVE already exists, skipping download"
    else
        URL=${URLS[i]}
        wget -P "$ORIG" "$URL"
        if [ -f "$ARCHIVE" ]; then
            echo "$URL successfully downloaded."
        else
            echo "$URL not successfully downloaded."
            exit 1
        fi
    fi
    FILE=${ARCHIVE: -4}
    if [ -e "$FILE" ]; then
        echo "$FILE already exists, skipping extraction"
    else
        tar -C "$ORIG" -xzvf "$ARCHIVE"
    fi
done

echo "pre-processing train data..."
for SRC in "${LANGS[@]}"; do
    for TRG in "${LANGS[@]}"; do
        if [[ $SRC != "$TRG" ]]; then
            for LANG in $SRC $TRG; do
                cat "$ORIG/$UNARCHIVED_NAME/train.tags.${SRC}-${TRG}.${LANG}" \
                    | grep -v '<url>' \
                    | grep -v '<talkid>' \
                    | grep -v '<keywords>' \
                    | grep -v '<speaker>' \
                    | grep -v '<reviewer' \
                    | grep -v '<translator' \
                    | grep -v '<doc' \
                    | grep -v '</doc>' \
                    | sed -e 's/<title>//g' \
                    | sed -e 's/<\/title>//g' \
                    | sed -e 's/<description>//g' \
                    | sed -e 's/<\/description>//g' \
                    | sed 's/^\s*//g' \
                    | sed 's/\s*$//g' \
                    > "$DATA/train.${SRC}-${TRG}.${LANG}"
            done
        fi
    done
done

echo "pre-processing dev data..."

# sample file name: IWSLT17.TED.dev2010.ro-it.ro.xml

for SRC in "${LANGS[@]}"; do
    for TRG in "${LANGS[@]}"; do
        if [[ $SRC != "$TRG" ]]; then
            for LANG in $SRC $TRG; do
                grep '<seg id' "$ORIG/$UNARCHIVED_NAME/IWSLT17.TED.dev2010.${SRC}-${TRG}.${LANG}.xml" \
                | sed -e 's/<seg id="[0-9]*">\s*//g' \
                | sed -e 's/\s*<\/seg>\s*//g' \
                | sed -e "s/\’/\'/g" \
                > "$DATA/dev.${SRC}-${TRG}.${LANG}"
            done
        fi
    done
done

echo "pre-processing test data..."

for SRC in "${LANGS[@]}"; do
    for TRG in "${LANGS[@]}"; do
        if [[ $SRC != "$TRG" ]]; then
            for LANG in $SRC $TRG; do
                grep '<seg id' "$ORIG/$UNARCHIVED_NAME/IWSLT17.TED.tst2010.${SRC}-${TRG}.${LANG}.xml" \
                | sed -e 's/<seg id="[0-9]*">\s*//g' \
                | sed -e 's/\s*<\/seg>\s*//g' \
                | sed -e "s/\’/\'/g" \
                > "$DATA/test.${SRC}-${TRG}.${LANG}"
            done
        fi
    done
done
