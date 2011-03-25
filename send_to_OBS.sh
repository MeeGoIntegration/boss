#!/bin/bash

echo "Ensure the .spec and changelog versions match - hit return"
read dummy

OBSDIR=../Project:MINT:Testing/boss
BUILD=../build-area

rm -f ../build_area/boss_*
git-buildpackage --git-ignore-new -S -uc -us -tc
rm -f $OBSDIR/boss_*
cp rpm/boss.spec $OBSDIR/

mv $BUILD/boss_*dsc $OBSDIR/
mv $BUILD/boss_*gz $OBSDIR/

cd $OBSDIR
osc ar
osc ci -m"New release"
