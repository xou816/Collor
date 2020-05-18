//
//  CollorStacks
//
//  Created by Trendel Alexandre on 11/05/2020.
//  Copyright © 2020 OUI.sncf. All rights reserved.
//

import UIKit

public protocol Adaptable {
    associatedtype Adapter
    associatedtype Delegate = ()
    func update(with adapter: Adapter)
    static func create() -> Self
}

extension Adaptable where Self: UIResponder {
    public var delegate: Delegate? {
        nextConformingResponder()
    }
}

extension UIResponder {
    func nextConformingResponder<T>() -> T? {
        guard let next = next else { return nil }
        if let next = next as? T {
            return next
        } else {
            return next.nextConformingResponder()
        }
    }
}

extension Adaptable where Self: UIView {
    public static func adapted(by adapter: Adapter) -> DescriptorItem  {
        .describe(create(), with: adapter)
    }
}

extension Adaptable where Self: UIViewController {
    public static func adapted(by adapter: Adapter) -> DescriptorItem  {
        .describe(create(), with: adapter)
    }
}

public struct StackAdapter: Diffable {
    let descriptors: [DescriptorItem]
    
    public init(@DescriptorBuilder builderClosure: () -> [DescriptorItem]) {
        self.descriptors = builderClosure()
    }
    
    public func isEqual(to other: Diffable?) -> Bool {
        return false
    }
}

public final class AdaptableStackView: UIViewController, Adaptable {
    
    public static func create() -> AdaptableStackView {
        return AdaptableStackView()
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private struct WeakViewLike {
        weak var viewLike: UIViewLike?
        init(_ viewLike: UIViewLike) {
            self.viewLike = viewLike
        }
    }
    
    private var descriptors = [DescriptorItem]()
    private var allChildren = [WeakViewLike]()
    
    public init(decoration: UIView? = nil, outerMargin: CGFloat = 0, innerMargin: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let decoration = decoration {
            view.addSubview(decoration, marginConstraint: outerMargin)
            decoration.translatesAutoresizingMaskIntoConstraints = false
            decoration.addSubview(stack, marginConstraint: innerMargin)
        } else {
            view.addSubview(stack, marginConstraint: outerMargin)
        }
    }
            
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(with adapter: StackAdapter) {
        let diff = CollorDiff(before: asDiffItems(descriptors),
                              after: asDiffItems(adapter.descriptors))
        view.layoutSubviews()
        UIView.animate(withDuration: 0.2, animations: {
            diff.reloaded.forEach { index in
                self.update(adapter.descriptors[index], at: index)
            }
            diff.deleted.sorted().reversed().forEach { index in
                self.remove(at: index)
            }
            diff.inserted.forEach { index in
                self.insert(adapter.descriptors[index], at: index)
            }
            diff.moved.forEach { (from, to) in
                // todo
            }
            self.view.layoutSubviews()
        })
        
    }
    
    private func asDiffItems(_ descriptors: [DescriptorItem]) -> [CollorDiff<Int, String>.DiffItem] {
        descriptors.enumerated().map { index, desc in
            CollorDiff<Int, String>.DiffItem(index, "\(desc.identifier)_\(index)", desc.adapter as? Diffable)
        }
    }
    
    private func update(_ descriptor: DescriptorItem, at index: Int) {
        guard let viewLike = allChildren[index].viewLike else { return }
        descriptor.update(viewLike)
        descriptors[index] = descriptor
    }
    
    private func insert(_ descriptor: DescriptorItem, at index: Int) {
        let viewLike = descriptor.create()
        descriptor.update(viewLike)
        descriptors.insert(descriptor, at: index)
        insert(viewLike, at: index)
    }
    
    private func insert(_ viewLike: UIViewLike, at index: Int) {
        allChildren.insert(WeakViewLike(viewLike), at: index)
        stack.insertArrangedSubview(viewLike.uiView, at: index)
        if let controller = viewLike.uiViewController {
            addChild(controller)
        }
    }
    
    private func remove(at index: Int) {
        stack.arrangedSubviews[index].isHidden = true
        allChildren.remove(at: index)
        descriptors.remove(at: index)
    }
}

public struct StackDescriptor: Descriptor {
    let decoration: () -> UIView
    let adapter: StackAdapter
    let outerMargin: CGFloat
    let innerMargin: CGFloat
    
    public init(
        _ decoration: @escaping @autoclosure () -> UIView,
        outerMargin: CGFloat = 0,
        innerMargin: CGFloat = 0,
        @DescriptorBuilder builderClosure: @escaping () -> [DescriptorItem]) {
        self.decoration = decoration
        self.outerMargin = outerMargin
        self.innerMargin = innerMargin
        self.adapter = StackAdapter(builderClosure: builderClosure)
    }
    
    public var items: [DescriptorItem] {
        [.describe(AdaptableStackView(
            decoration: self.decoration(),
            outerMargin: self.outerMargin,
            innerMargin: self.innerMargin), with: adapter)]
    }
}

extension UIView {
    
    func addSubview(_ child: UIView, marginConstraint margin: CGFloat) {
        self.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: self.topAnchor, constant: margin),
            child.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            child.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -2*margin),
            child.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -2*margin)
        ])
    }
}
