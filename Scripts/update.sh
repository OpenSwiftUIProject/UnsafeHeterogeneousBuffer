#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

PACKAGE_ROOT="$(dirname $(dirname $(filepath $0)))"

UPSTREAM_REPO_URL="https://github.com/OpenSwiftUIProject/OpenSwiftUI"
UPSTREAM_BRANCH="main"

# Accept custom commit hash as argument, otherwise fetch latest from main
if [ -n "$1" ]; then
  UPSTREAM_COMMIT_HASH="$1"
  echo "Using provided commit hash: $UPSTREAM_COMMIT_HASH"
else
  # Fetch latest commit hash from main branch
  echo "Fetching latest commit from $UPSTREAM_BRANCH branch..."
  UPSTREAM_COMMIT_HASH=$(git ls-remote $UPSTREAM_REPO_URL refs/heads/$UPSTREAM_BRANCH | cut -f1)
  echo "Latest commit hash: $UPSTREAM_COMMIT_HASH"
fi

REPO_DIR="$PACKAGE_ROOT/.repos/OpenSwiftUI"

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

# Copy files first, then apply transformations
mkdir -p $SOURCE_DES
cp -r $SOURCE_DIR/UnsafeHeterogeneousBuffer.swift $SOURCE_DES/

mkdir -p $TEST_DEST
cp -r $TEST_DIR/UnsafeHeterogeneousBufferTests.swift $TEST_DEST/

# Apply semantic transformations instead of patches
echo "Applying semantic transformations..."
bash "$PACKAGE_ROOT/Scripts/apply_transformations.sh" \
    "$SOURCE_DES/UnsafeHeterogeneousBuffer.swift" \
    "$TEST_DEST/UnsafeHeterogeneousBufferTests.swift"

# Save upstream commit hash for reference
echo "$UPSTREAM_COMMIT_HASH" > "$PACKAGE_ROOT/.upstream-commit"

echo ""
echo "✓ Update complete!"
echo "  Upstream commit: $UPSTREAM_COMMIT_HASH"
echo ""

# Commit changes automatically
git add Sources/UnsafeHeterogeneousBuffer/UnsafeHeterogeneousBuffer.swift \
        Tests/UnsafeHeterogeneousBufferTests/UnsafeHeterogeneousBufferTests.swift \
        .upstream-commit

git commit -m "$(cat <<EOF
Update from OpenSwiftUI upstream

Upstream: https://github.com/OpenSwiftUIProject/OpenSwiftUI/blob/$UPSTREAM_COMMIT_HASH/Sources/OpenSwiftUICore/Data/DynamicProperty/UnsafeHeterogeneousBuffer.swift

Transformations applied:
- Changed package → public access control
- Removed @_spi(ForOpenSwiftUIOnly) attributes
- Updated module references
- Added compatibility test conditionals
- Replaced OpenSwiftUI helpers with standard Swift

EOF
)"

echo "✓ Changes committed successfully!"
echo ""
echo "Next steps:"
echo "  1. Review the commit: git show"
echo "  2. Test the build: swift build"
echo "  3. Run tests: swift test"
