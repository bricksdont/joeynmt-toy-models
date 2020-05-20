#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

tools=$base/tools
mkdir -p $tools

echo "Make sure this script is executed AFTER you have activated a virtualenv"

# install joeynmt

git clone https://github.com/bricksdont/joeynmt.git $tools/joeynmt

# if necessary: first check out the correct branch:

(cd $tools/joeynmt && git checkout factors_complete && git pull)

(cd $tools/joeynmt && pip install --upgrade .)

# fix torch version, for reproducibility

pip install --upgrade torch==1.4.0

# install Moses scripts for preprocessing

git clone https://github.com/bricksdont/moses-scripts $tools/moses-scripts
