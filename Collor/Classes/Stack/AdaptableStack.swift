//
//  CollorStacks
//
//  Created by Trendel Alexandre on 11/05/2020.
//  Copyright © 2020 OUI.sncf. All rights reserved.
//

import UIKit

/// Adaptable views or controllers can be updated using an Adapter
public protocol Adaptable {
    
    /// A view model for the Adaptable view
    /// Should conform to Diffable if possible
    associatedtype Adapter
    
    /// Event delegate for interactive views and controls
    associatedtype Delegate = ()
    
    /// Update view
    func update(with adapter: Adapter)
    
    /// Create an instance of the Adaptable view
    /// Only needed when using automatic descriptors provided by `adapted(by:)`,
    /// otherwise, feel free to error here and use custom descriptors instead.
    static func create() -> Self
}

extension Adaptable where Self: UIResponder {
    
    public static func create() -> Self {
        fatalError("Adaptable.create() not implemented! Use a custom Descriptor if you cannot implement a no-argument factory function")
    }
    
    /// Find delegate in the hierarchy
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
    
    /// Create a descriptor for the view, with the provided Adapter
    public static func adapted(by adapter: Adapter) -> DescriptorItem  {
        .describe(create(), with: adapter)
    }
}

extension Adaptable where Self: UIViewController {
    
    /// Create a descriptor for the controller, with the provided Adapter
    public static func adapted(by adapter: Adapter) -> DescriptorItem  {
        .describe(create(), with: adapter)
    }
}

/// Adapter for AdaptableStackViews
public struct StackAdapter: Diffable {
    let items: [DescriptorItem]
    
    public init(@DescriptorBuilder builderClosure: () -> Descriptor) {
        self.items = builderClosure().items
    }
    
    public func isEqual(to other: Diffable?) -> Bool {
        // Always return false to perform diff on child views
        return false
    }
}

/// A managed StackView that is able to update its children
/// Children should not be added directly: use a StackAdapter instead
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
    
    /// Weak container for UIViews and UIViewControllers
    /// Safer since these children already appear in `children`/`arrangedSubviews`
    private struct WeakViewLike {
        weak var viewLike: UIViewLike?
        init(_ viewLike: UIViewLike) {
            self.viewLike = viewLike
        }
    }
    
    private var descriptors = [DescriptorItem]()
    private var allChildren = [WeakViewLike]()
    
    /// Create a new Stack with an optional decoration view
    /// Outer margin adds space around the decoration, and inner margin adds
    /// space around the stacked views
    public init(decoration: UIView? = nil, outerMargin: CGFloat = 0, innerMargin: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let decoration = decoration {
            view.addSubview(decoration, marginConstraint: outerMargin)
            decoration.translatesAutoresizingMaskIntoConstraints = false
            decoration.addSubview(stack, marginConstraint: innerMargin)
        } else {
            view.addSubview(stack, marginConstraint: outerMargin + innerMargin)
        }
    }
            
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func printDiff(_ diff: CollorDiff<Int, String>, newItems: [DescriptorItem]) {
        print("----------------")
        let reloaded = diff.reloaded.map { "\($0)=\(descriptors[$0].identifier)" }
        print("reloaded = \(reloaded)")
        let deleted = diff.deleted.map { "\($0)=\(descriptors[$0].identifier)" }
        print("deleted  = \(deleted)")
        let inserted = diff.inserted.map { "\($0)=\(newItems[$0].identifier)" }
        print("inserted = \(inserted)")
    }
    
    /// Update the view with the provided StackAdapter
    public func update(with adapter: StackAdapter) {
        let newDescriptors = adapter.items
        let diff = CollorDiff(before: asDiffItems(descriptors),
                              after: asDiffItems(newDescriptors))
        
        // printDiff(diff, newItems: newDescriptors)
        
        view.layoutSubviews()
        
        let toDelete = diff.deleted.sorted().reversed().map { index in
            self.remove(at: index)
        }
        
        let toUnhide = diff.inserted.map { index -> UIView in
            let view = self.insert(newDescriptors[index], at: index)
            view.hide()
            return view
        }
        
        UIView.animate(withDuration: 0.15, animations: {
            toDelete.forEach { view in view.hide() }
            toUnhide.forEach { view in view.show() }
            diff.reloaded.forEach { index in
                self.update(newDescriptors[index], at: index)
            }
        }, completion: { _ in
            toDelete.forEach { view in view.removeFromSuperview() }
        })
    }

    private func asDiffItems(_ descriptors: [DescriptorItem]) -> [CollorDiff<Int, String>.DiffItem] {
        return descriptors.enumerated().map { index, desc in
            CollorDiff<Int, String>.DiffItem(index, desc.identifier, desc.adapter as? Diffable)
        }
    }
    
    private func update(_ descriptor: DescriptorItem, at index: Int) {
        guard let viewLike = allChildren[index].viewLike else { return }
        descriptor.update(viewLike)
        descriptors[index] = descriptor
    }
    
    private func insert(_ descriptor: DescriptorItem, at index: Int) -> UIView {
        let viewLike = descriptor.create()
        descriptor.update(viewLike)
        descriptors.insert(descriptor, at: index)
        insert(viewLike, at: index)
        return viewLike.uiView
    }
    
    private func insert(_ viewLike: UIViewLike, at index: Int) {
        allChildren.insert(WeakViewLike(viewLike), at: index)
        stack.insertArrangedSubview(viewLike.uiView, at: index)
        if let controller = viewLike.uiViewController {
            addChild(controller)
        }
    }
    
    private func remove(at index: Int) -> UIView {
        allChildren.remove(at: index)
        descriptors.remove(at: index)
        return stack.arrangedSubviews[index]
    }
}

/// A utility Descriptor to insert a nested AdaptableStackView
public struct StackDescriptor: Descriptor {
    let decoration: () -> UIView?
    let adapter: StackAdapter
    let outerMargin: CGFloat
    let innerMargin: CGFloat
    
    public init(
        _ decoration: @escaping @autoclosure () -> UIView?,
        outerMargin: CGFloat = 0,
        innerMargin: CGFloat = 0,
        @DescriptorBuilder builderClosure: @escaping () -> Descriptor) {
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

fileprivate extension UIView {
    
    func show() {
        isHidden = false
        alpha = 1
    }
    
    func hide() {
        isHidden = true
        alpha = 0
    }
    
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
