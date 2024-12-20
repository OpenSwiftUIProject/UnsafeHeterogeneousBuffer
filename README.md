# UnsafeHeterogeneousBuffer

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FUnsafeHeterogeneousBuffer%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FUnsafeHeterogeneousBuffer%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer)

[![codecov](https://codecov.io/gh/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/graph/badge.svg?token=VDKQVOP20I)](https://codecov.io/gh/OpenSwiftUIProject/UnsafeHeterogeneousBuffer) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit)

## Overview

| **Workflow** | **CI Status** |
|-|:-|
| **Compatibility Test** | [![Compatibility tests](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/compatibility_tests.yml/badge.svg)](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/compatibility_tests.yml) |
| **macOS Unit Test** | [![macOS](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/macos.yml/badge.svg)](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/macos.yml) |
| **iOS Unit Test** | [![iOS](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/ios.yml/badge.svg)](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/ios.yml) |
| **Ubuntu 22.04 Unit Test** | [![Ubuntu](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/actions/workflows/ubuntu.yml) |

## Getting Started

In your `Package.swift` file, add the following dependency to your `dependencies` argument:

```swift
.package(url: "https://github.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer.git", from: "0.1.0"),
```

Then add the dependency to any targets you've declared in your manifest:

```swift
.target(
    name: "MyTarget", 
    dependencies: [
        .product(name: "UnsafeHeterogeneousBuffer", package: "UnsafeHeterogeneousBuffer"),
    ]
),
```

## Usage

### Plain usage

To make use of `UnsafeHeterogeneousBuffer`, first create your `VTable` implementation and then
use `append` method to add elements to the buffer.

```swift
import UnsafeHeterogeneousBuffer

final class VTable<Value>: _UnsafeHeterogeneousBuffer_VTable {
    override class func hasType<T>(_ type: T.Type) -> Bool {
        Value.self == T.self
    }
    
    override class func moveInitialize(elt: _UnsafeHeterogeneousBuffer_Element, from: _UnsafeHeterogeneousBuffer_Element) {
        let dest = elt.body(as: Value.self)
        let source = from.body(as: Value.self)
        dest.initialize(to: source.move())
    }
    
    override class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        elt.body(as: Value.self).deinitialize(count: 1)
    }
}

var buffer = UnsafeHeterogeneousBuffer()
defer { buffer.destroy() }      
_ = buffer.append(UInt32(1), vtable: VTable<Int32>.self)
_ = buffer.append(Int(-1), vtable: VTable<Int>.self)
_ = buffer.append(Double.infinity, vtable: VTable<Double>.self)
```

### Advanced usage

Or you can use `UnsafeHeterogeneousBuffer` internally to implement your own buffer type.

```swift
protocol P {
    mutating func modify(inputs: inout Int)
}

extension P {
    mutating func modify(inputs: inout Int) {}
}

struct PBuffer {
    var startIndex: UnsafeHeterogeneousBuffer.Index { contents.startIndex }
    var endIndex: UnsafeHeterogeneousBuffer.Index { contents.endIndex }

    var contents: UnsafeHeterogeneousBuffer
    
    typealias Index = UnsafeHeterogeneousBuffer.Index
    
    struct Element {
        var base: UnsafeHeterogeneousBuffer.Element
    }
    
    private class VTable: _UnsafeHeterogeneousBuffer_VTable {
        class func modify(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout Int) {}
    }
    
    private final class _VTable<T>: VTable where T: P{
        override class func modify(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout Int) {
            elt.body(as: T.self).pointee.modify(inputs: &inputs)
        }
    }
}
```

Please see UnsafeHeterogeneousBuffer [documentation site](https://swiftpackageindex.com/OpenSwiftUIProject/UnsafeHeterogeneousBuffer/main/documentation/unsafeheterogeneousbuffer)
for more detailed information about the library.

## License

See LICENSE file - MIT

## Related Projects

- https://github.com/OpenSwiftUIProject/OpenSwiftUI

## Star History

<a href="https://star-history.com/#OpenSwiftUIProject/UnsafeHeterogeneousBuffer&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/UnsafeHeterogeneousBuffer&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/UnsafeHeterogeneousBuffer&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=OpenSwiftUIProject/UnsafeHeterogeneousBuffer&type=Date" />
  </picture>
</a>
