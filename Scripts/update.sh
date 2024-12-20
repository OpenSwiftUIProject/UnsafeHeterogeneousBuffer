#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

PACKAGE_ROOT="$(dirname $(dirname $(filepath $0)))"

UPSTREAM_REPO_URL="https://github.com/OpenSwiftUIProject/OpenSwiftUI"
UPSTREAM_COMMIT_HASH="958481bf911f808a0f0894654fd6ddf3338a30f2"

REPO_DIR="$PACKAGE_ROOT/.repos/OpenSwiftUI"
PATCHES_DIR="$PACKAGE_ROOT/Patches"

SOURCE_DIR="$REPO_DIR/Sources/OpenSwiftUICore/Data/DynamicProperty"
SOURCE_DES="$PACKAGE_ROOT/Sources/UnsafeHeterogeneousBuffer"

TEST_DIR="$REPO_DIR/Tests/OpenSwiftUICoreTests/Data/DynamicProperty"
TEST_DEST="$PACKAGE_ROOT/Tests/UnsafeHeterogeneousBufferTests"

rm -rf $REPO_DIR

git clone --depth 1 $UPSTREAM_REPO_URL $REPO_DIR
cd $REPO_DIR
git fetch --depth=1 origin $UPSTREAM_COMMIT_HASH
git -c advice.detachedHead=false checkout $UPSTREAM_COMMIT_HASH

cd $PACKAGE_ROOT

if [ -d "$PATCHES_DIR" ]; then
    for patch in $(ls $PATCHES_DIR/*.patch | sort); do
        [ -e "$patch" ] || continue
        git -C $REPO_DIR apply "$patch"
    done
fi

mkdir -p $SOURCE_DES
cp -r $SOURCE_DIR/UnsafeHeterogeneousBuffer.swift $SOURCE_DES/

mkdir -p $TEST_DEST
cp -r $TEST_DIR/UnsafeHeterogeneousBufferTests.swift $TEST_DEST/
