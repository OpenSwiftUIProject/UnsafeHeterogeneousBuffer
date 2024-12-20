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
