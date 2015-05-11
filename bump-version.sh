#!/bin/sh +v
NEW_VER=$@

sed -i -r "s/VERSION\s*=\s*[0-9]+\.[0-9]+\.[0-9]+/VERSION = ${NEW_VER}/g" makefile
sed -i -r "s/VERSION\s*=\s*\"[0-9]+\.[0-9]+\.[0-9]+\"/VERSION = \"${NEW_VER}\"/g" src/version_.d
make
git commit -a -m "Bumped version to ${NEW_VER}"
