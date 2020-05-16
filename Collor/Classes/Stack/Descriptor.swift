//
//  Descriptor.swift
//  Collor
//
//  Created by Trendel Alexandre on 15/05/2020.
//

import UIKit

// type-erased descriptor
public struct DescriptorItem {
    let identifier: String
    let adapter: Any
    let update: (UIViewLike) -> Void
    let create: () -> UIViewLike
}

// wrapper around multiple descriptors
public protocol Descriptor {
    func items() -> [DescriptorItem]
}

extension DescriptorItem: Descriptor {
    public func items() -> [DescriptorItem] {
        [self]
    }
}

extension DescriptorItem {

    public static func describe<V>(
        _ view: @autoclosure @escaping () -> V,
        with adapter: V.Adapter) -> DescriptorItem
        where V: UIView & Adaptable {
            
            DescriptorItem(
                identifier: "\(V.self)",
                adapter: adapter,
                update: { view in
                    if let castView = view as? V {
                        castView.update(with: adapter)
                    }
                },
                create: view)
    }
    
    public static func describe<V>(
        controller: @autoclosure @escaping () -> V,
        with adapter: V.Adapter) -> DescriptorItem
        where V: UIViewController & Adaptable {
            
            DescriptorItem(
                identifier: "\(V.self)",
                adapter: adapter,
                update: { controller in
                    if let controller = controller as? V {
                        controller.update(with: adapter)
                    }
                },
                create: controller)
    }
}

public struct If: Descriptor {
    let condition: Bool
    let builderClosure: () -> [DescriptorItem]
    
    public init(_ condition: Bool, @DescriptorBuilder builderClosure: @escaping () -> [DescriptorItem]) {
        self.condition = condition
        self.builderClosure = builderClosure
    }
    
    public func items() -> [DescriptorItem] {
        condition ? builderClosure() : []
    }
}

public struct Section: Descriptor {
    let builderClosure: () -> [DescriptorItem]
    
    public init(@DescriptorBuilder builderClosure: @escaping () -> [DescriptorItem]) {
        self.builderClosure = builderClosure
    }
    
    public func items() -> [DescriptorItem] {
        builderClosure()
    }
}

@_functionBuilder
public class DescriptorBuilder {
    
    public static func buildBlock(_ descriptors: DescriptorItem?...) -> [DescriptorItem] {
        descriptors.compactMap { $0 }
    }
    
    public static func buildBlock(_ descriptors: Descriptor?...) -> [DescriptorItem] {
        descriptors.compactMap { $0 }.flatMap { $0.items() }
    }
}

// MARK: --------------

protocol UIViewLike: class {
    var uiView: UIView { get }
    var uiViewController: UIViewController? { get }
}

extension UIView: UIViewLike {
    var uiView: UIView {
        if let cell = self as? UICollectionViewCell {
            return cell.contentView
        } else {
            return self
        }
    }
    var uiViewController: UIViewController? { nil }
}

extension UIViewController: UIViewLike {
    var uiView: UIView { self.view }
    var uiViewController: UIViewController? { self }
}

extension Diffable where Self: Hashable {
    public func isEqual(to other: Diffable?) -> Bool {
        if let other = other as? Self {
            return other.hashValue == hashValue
        }
        return false
    }
}
