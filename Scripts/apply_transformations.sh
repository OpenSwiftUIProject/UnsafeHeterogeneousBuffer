#!/bin/bash

# Semantic patching script to transform OpenSwiftUI source files
# for use in UnsafeHeterogeneousBuffer package

set -e

SOURCE_FILE="$1"
TEST_FILE="$2"

if [ -z "$SOURCE_FILE" ] || [ -z "$TEST_FILE" ]; then
    echo "Usage: $0 <source_file> <test_file>"
    exit 1
fi

echo "Applying semantic transformations..."

# ============================================================================
# Transform Source File
# ============================================================================

echo "  → Transforming $SOURCE_FILE"

# 1. Update header comment - change module name
sed -i '' 's|//  OpenSwiftUICore|//  UnsafeHeterogeneousBuffer|' "$SOURCE_FILE"

# 2. Remove audit status lines
sed -i '' '/^\/\/  Audited for/d' "$SOURCE_FILE"
sed -i '' '/^\/\/  Status:/d' "$SOURCE_FILE"
sed -i '' '/^\/\/  ID:/d' "$SOURCE_FILE"

# 3. Remove empty comment line after header (sed: delete line 4 if it's just "//")
sed -i '' '4{/^\/\/$/d;}' "$SOURCE_FILE"

# 4. Change package → public for main struct
sed -i '' 's/^package struct UnsafeHeterogeneousBuffer/public struct UnsafeHeterogeneousBuffer/' "$SOURCE_FILE"

# 5. Change package → public for typealiases
sed -i '' 's/^[[:space:]]*package typealias/    public typealias/' "$SOURCE_FILE"

# 6. Change package → public for nested structs
sed -i '' 's/^[[:space:]]*package struct Index/    public struct Index/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package struct Item/    public struct Item/' "$SOURCE_FILE"

# 7. Change package → public for static functions in Index
sed -i '' 's/^[[:space:]]*package static func/        public static func/' "$SOURCE_FILE"

# 8. Change package → public for properties
sed -i '' 's/^[[:space:]]*package var count/    public var count/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package var isEmpty/    public var isEmpty/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package var startIndex/    public var startIndex/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package var endIndex/    public var endIndex/' "$SOURCE_FILE"

# 9. Change package → public for init
sed -i '' 's/^[[:space:]]*package init()/    public init()/' "$SOURCE_FILE"

# 10. Change package → public for functions
sed -i '' 's/^[[:space:]]*package func destroy()/    public func destroy()/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package func formIndex/    public func formIndex/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package func index(after/    public func index(after/' "$SOURCE_FILE"

# 11. Change package → public for subscript
sed -i '' 's/^[[:space:]]*package subscript/    public subscript/' "$SOURCE_FILE"

# 12. Change package → public for append function
sed -i '' 's/^[[:space:]]*package mutating func append/    public mutating func append/' "$SOURCE_FILE"

# 13. Remove @_spi(ForOpenSwiftUIOnly) lines
sed -i '' '/@_spi(ForOpenSwiftUIOnly)/d' "$SOURCE_FILE"

# 14. Change package → public for _UnsafeHeterogeneousBuffer_Element
sed -i '' 's/^[[:space:]]*package func hasType/    public func hasType/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package func vtable/    public func vtable/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package func body/    public func body/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package var flags/    public var flags/' "$SOURCE_FILE"
sed -i '' 's/^[[:space:]]*package var address/    public var address/' "$SOURCE_FILE"

# 15. Replace OpenSwiftUI-specific helper functions
sed -i '' 's/_openSwiftUIBaseClassAbstractMethod()/preconditionFailure("")/g' "$SOURCE_FILE"

echo "  ✓ Source file transformed"

# ============================================================================
# Transform Test File
# ============================================================================

echo "  → Transforming $TEST_FILE"

# 1. Update header comment
sed -i '' 's|//  OpenSwiftUICoreTests|//  UnsafeHeterogeneousBufferTests|' "$TEST_FILE"

# 2. Replace imports
sed -i '' '/@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore/d' "$TEST_FILE"
sed -i '' 's|@testable import OpenSwiftUICore|#if UNSAFEHETEROGENEOUSBUFFER_SWIFTUI_COMPATIBILITY_TEST\
import SwiftUI\
#else\
@testable import UnsafeHeterogeneousBuffer\
#endif|' "$TEST_FILE"

# 3. Wrap internal implementation checks with conditional compilation
# We need to add #if !UNSAFEHETEROGENEOUSBUFFER_SWIFTUI_COMPATIBILITY_TEST around index/offset/available checks

# Find lines with index.index, index.offset, or buffer.available and wrap them
awk '
    /#expect\(index\.index == / || /#expect\(index\.offset == / || /#expect\(buffer\.available == / {
        if (!in_block) {
            print "            #if !UNSAFEHETEROGENEOUSBUFFER_SWIFTUI_COMPATIBILITY_TEST"
            in_block = 1
        }
        print
        next_needs_endif = 1
        next
    }
    {
        if (next_needs_endif && $0 !~ /#expect\(index\.(index|offset) == / && $0 !~ /#expect\(buffer\.available == /) {
            print "            #endif"
            in_block = 0
            next_needs_endif = 0
        }
        print
    }
' "$TEST_FILE" > "$TEST_FILE.tmp" && mv "$TEST_FILE.tmp" "$TEST_FILE"

# 4. Add index(atOffset:) extension if not present
if ! grep -q "extension Collection" "$TEST_FILE"; then
    cat >> "$TEST_FILE" << 'EOF'

extension Collection {
    package func index(atOffset n: Int) -> Index {
        index(startIndex, offsetBy: n)
    }
}
EOF
fi

echo "  ✓ Test file transformed"

echo "✓ All transformations applied successfully"
