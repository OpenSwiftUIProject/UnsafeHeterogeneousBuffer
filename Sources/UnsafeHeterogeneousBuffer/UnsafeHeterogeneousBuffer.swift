//
//  UnsafeHeterogeneousBuffer.swift
//  UnsafeHeterogeneousBuffer

public struct UnsafeHeterogeneousBuffer: Collection {
    var buf: UnsafeMutableRawPointer!
    var available: Int32
    var _count: Int32
    
    public typealias VTable = _UnsafeHeterogeneousBuffer_VTable
    public typealias Element = _UnsafeHeterogeneousBuffer_Element
    
    public struct Index: Equatable, Comparable {
        var index: Int32
        var offset: Int32
        
        public static func < (lhs: Index, rhs: Index) -> Bool {
            lhs.index < rhs.index
        }
        
        public static func == (a: Index, b: Index) -> Bool {
            a.index == b.index && a.offset == b.offset
        }
    }
    
    public struct Item {
        let vtable: _UnsafeHeterogeneousBuffer_VTable.Type
        let size: Int32
        var flags: UInt32
    }
    
    public var count: Int { Int(_count) }
    public var isEmpty: Bool { _count == 0 }
    
    public var startIndex: Index {
        Index(index: 0, offset: 0)
    }
    public var endIndex: Index {
        Index(index: _count, offset: 0)
    }
    
    public init() {
        buf = nil
        available = 0
        _count = 0
    }
    
    private mutating func allocate(_ bytes: Int) -> UnsafeMutableRawPointer {
        var count = _count
        var offset = 0
        var size = 0
        while count != 0 {
            let itemSize = buf
                .advanced(by: offset)
                .assumingMemoryBound(to: Item.self)
                .pointee
                .size
            offset &+= Int(itemSize)
            count &-= 1
            offset = count == 0 ? 0 : offset
            size &+= Int(itemSize)
        }
        // Grow buffer if needed
        if Int(available) < bytes {
            growBuffer(by: bytes, capacity: size + Int(available))
        }
        let ptr = buf.advanced(by: size)
        available = available - Int32(bytes)
        return ptr
    }
    
    private mutating func growBuffer(by size: Int, capacity: Int) {
        let expectedSize = size + capacity
        var allocSize = Swift.max(capacity &* 2, 64)
        while allocSize < expectedSize {
            allocSize &*= 2
        }
        let allocatedBuffer = UnsafeMutableRawPointer.allocate(
            byteCount: allocSize,
            alignment: .zero
        )
        if let buf {
            var count = _count
            if count != 0 {
                var itemSize: Int32 = 0
                var oldBuffer = buf
                var newBuffer = allocatedBuffer
                repeat {
                    count &-= 1
                    let newItemPointer = newBuffer.assumingMemoryBound(to: Item.self)
                    let oldItemPointer = oldBuffer.assumingMemoryBound(to: Item.self)
                    
                    if count == 0 {
                        itemSize = 0
                    } else {
                        itemSize &+= oldItemPointer.pointee.size
                    }
                    newItemPointer.initialize(to: oldItemPointer.pointee)                    
                    oldItemPointer.pointee.vtable.moveInitialize(
                        elt: .init(item: newItemPointer),
                        from: .init(item: oldItemPointer)
                    )
                    let size = Int(oldItemPointer.pointee.size)
                    oldBuffer += size
                    newBuffer += size
                } while count != 0 || itemSize != 0
                
            }
            buf.deallocate()
        }
        buf = allocatedBuffer
        available += Int32(allocSize - capacity)
    }
    
    public func destroy() {
        defer { buf?.deallocate() }
        guard _count != 0 else {
            return
        }
        var count = _count
        var offset = 0
        while count != 0 {
            let itemPointer = buf
                .advanced(by: offset)
                .assumingMemoryBound(to: Item.self)
            itemPointer.pointee.vtable.deinitialize(elt: .init(item: itemPointer))
            offset &+= Int(itemPointer.pointee.size)
            count &-= 1
        }
    }
    
    public func formIndex(after index: inout Index) {
        index = self.index(after: index)
    }
    
    public func index(after index: Index) -> Index {
        let item = self[index].item.pointee
        let newIndex = index.index &+ 1
        if newIndex == _count {
            return Index(index: newIndex, offset: 0)
        } else {
            let newOffset = index.offset &+ item.size
            return Index(index: newIndex, offset: newOffset)
        }
    }
    
    public subscript(index: Index) -> Element {
        .init(item: buf
            .advanced(by: Int(index.offset))
            .assumingMemoryBound(to: Item.self)
        )
    }
    
    @discardableResult
    public mutating func append<T>(_ value: T, vtable: VTable.Type) -> Index {
        let bytes = MemoryLayout<T>.size + MemoryLayout<UnsafeHeterogeneousBuffer.Item>.size
        let pointer = allocate(bytes)
        let element = _UnsafeHeterogeneousBuffer_Element(item: pointer.assumingMemoryBound(to: Item.self))
        element.item.initialize(to: Item(vtable: vtable, size: Int32(bytes), flags: 0))
        element.body(as: T.self).initialize(to: value)
        let index = Index(index: _count, offset: Int32(pointer - buf))
        _count += 1
        return index
    }
}

public struct _UnsafeHeterogeneousBuffer_Element {
    var item: UnsafeMutablePointer<UnsafeHeterogeneousBuffer.Item>
    
    public func hasType<T>(_ type: T.Type) -> Bool {
        item.pointee.vtable.hasType(type)
    }
    
    public func vtable<T>(as type: T.Type) -> T.Type where T: _UnsafeHeterogeneousBuffer_VTable {
        address.assumingMemoryBound(to: Swift.type(of: type)).pointee
    }
    
    public func body<T>(as type: T.Type) -> UnsafeMutablePointer<T> {
        UnsafeMutableRawPointer(item.advanced(by: 1)).assumingMemoryBound(to: type)
    }
    
    public var flags: UInt32 {
        get { item.pointee.flags }
        nonmutating set { item.pointee.flags = newValue }
    }
    
    public var address: UnsafeRawPointer {
        UnsafeRawPointer(item)
    }
}

@available(*, unavailable)
extension _UnsafeHeterogeneousBuffer_Element: Sendable {}

open class _UnsafeHeterogeneousBuffer_VTable {
    open class func hasType<T>(_ type: T.Type) -> Bool {
        false
    }
    
    open class func moveInitialize(elt: _UnsafeHeterogeneousBuffer_Element, from: _UnsafeHeterogeneousBuffer_Element) {
        preconditionFailure("")
    }
    
    open class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        preconditionFailure("")
    }
}

@available(*, unavailable)
extension _UnsafeHeterogeneousBuffer_VTable: Sendable {}
