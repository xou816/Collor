//
//  Descriptor.swift
//  Collor
//
//  Created by Trendel Alexandre on 15/05/2020.
//

import UIKit

/// Type-erased descriptor thats bind a view to its adapter
public struct DescriptorItem {
    var identifier: String
    let adapter: Any
    let update: (UIViewLike) -> Void
    let create: () -> UIViewLike
    
    mutating func rename(prefix: String, suffix: String) -> DescriptorItem {
        identifier = "\(prefix)_\(identifier)_\(suffix)"
        return self
    }
}

class IdentifierGenerator {
    
    private var collisions = [String: Int]()
    private let prefix: String
    
    init(prefix: String) {
        self.prefix = prefix
    }
    
    func process(_ items: [DescriptorItem]) -> [DescriptorItem] {
        collisions.removeAll(keepingCapacity: true)
        return items.map { item in
            var item = item
            let count = collisions[item.identifier] ?? 0
            collisions[item.identifier] = count + 1
            return item.rename(prefix: prefix, suffix: "\(count)")
        }
    }
}

/// Descriptor wrapper
/// Useful to create utility descriptors
public protocol Descriptor {
    var items: [DescriptorItem] { get }
}

extension DescriptorItem: Descriptor {
    public var items: [DescriptorItem] {
        [self]
    }
}

extension Descriptor where Self: CollectionCellDescribable  {
    public var items: [DescriptorItem] {
        [DescriptorItem(
            identifier: identifier,
            adapter: getAdapter(),
            update: { viewLike in
                if let adaptable = viewLike as? CollectionCellAdaptable {
                    adaptable.update(with: self.getAdapter())
                }
            },
            create: {
                Bundle(for: Self.self)
                    .loadNibNamed(self.identifier, owner: nil, options: nil)?.first as! UIView
            })]
    }
}

extension DescriptorItem {

    /// Create a descriptor for an adaptable view
    public static func describe<V>(
        _ view: @autoclosure @escaping () -> V,
        with adapter: V.Adapter) -> DescriptorItem
        where V: UIView & Adaptable {
            
            describe(viewLike: view, with: adapter)
    }
    
    /// Create a descriptor for an adaptable controller
    public static func describe<V>(
        _ controller: @autoclosure @escaping () -> V,
        with adapter: V.Adapter) -> DescriptorItem
        where V: UIViewController & Adaptable {
            
            describe(viewLike: controller, with: adapter)
    }
    
    private static func describe<V>(
        viewLike: @autoclosure @escaping () -> V,
        with adapter: V.Adapter) -> DescriptorItem
        where V: UIViewLike & Adaptable {
            
            DescriptorItem(
                identifier: "\(V.self)",
                adapter: adapter,
                update: { viewLike in
                    if let viewLike = viewLike as? V {
                        viewLike.update(with: adapter)
                    }
                },
                create: viewLike)
    }
}

/// Descriptor thats returns items conditionnally
public struct If: Descriptor {
    private let generator = IdentifierGenerator(prefix: "If")
    let condition: Bool
    let builderClosure: () -> Descriptor
    
    public init(_ condition: Bool, @DescriptorBuilder builderClosure: @escaping () -> Descriptor) {
        self.condition = condition
        self.builderClosure = builderClosure
    }
    
    public var items: [DescriptorItem] {
        condition ? generator.process(builderClosure().items) : []
    }
}

/// Descriptor that wraps other descriptors
/// Useful to organize code in smaller chunks
/// Does not add unnecessary views to the hierarchy
public struct GroupDescriptor: Descriptor {
    private let generator = IdentifierGenerator(prefix: "Group")
    public let items: [DescriptorItem]
    
    public init(@DescriptorBuilder builderClosure: @escaping () -> Descriptor) {
        self.items = generator.process(builderClosure().items)
    }
    
    public init(items: [DescriptorItem]) {
        self.items = generator.process(items)
    }
}

@_functionBuilder
public class DescriptorBuilder {
        
    public static func buildBlock(_ descriptors: Descriptor?...) -> Descriptor {
        GroupDescriptor(items:
            descriptors.compactMap { $0 }.flatMap { $0.items })
    }
}

// Automatic Diffable conformance when Hashable
extension Diffable where Self: Hashable {
    public func isEqual(to other: Diffable?) -> Bool {
        if let other = other as? Self {
            return other.hashValue == hashValue
        }
        return false
    }
}

// MARK: Module private protocols

/// Protocol to abstract UIView/UIViewController
protocol UIViewLike: class {
    var uiView: UIView { get }
    var uiViewController: UIViewController? { get }
}

extension UIView: UIViewLike {
    var uiView: UIView { self }
    var uiViewController: UIViewController? { nil }
}

extension UIViewController: UIViewLike {
    var uiView: UIView { self.view }
    var uiViewController: UIViewController? { self }
}
