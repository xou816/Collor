//
//  CollectionCellDescribable.swift
//  Collor
//
//  Created by Guihal Gwenn on 16/03/17.
//  Copyright (c) 2017-present, Voyages-sncf.com. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC


public enum LayoutFitting {
    case estimatedHeight(estimatedHeight: CGFloat)
    case fixedHeight(height: CGFloat)
    case estimatedWidth(estimatedWidth: CGFloat)
    case fixedWidth(width: CGFloat)
    case fixed(width: CGFloat, height: CGFloat)
}

private struct AssociatedKeys {
    static var IndexPath = "collor_IndexPath"
    static var Size = "collor_Size"
}

public protocol CollectionCellDescribable : Identifiable {
    var identifier: String { get }
    var className: String { get }
    var selectable: Bool { get }
    var layoutFitting: LayoutFitting? { get }
    var adapter: CollectionAdapter { get }
    func size(_ collectionViewBounds: CGRect, sectionDescriptor: CollectionSectionDescribable) -> CGSize
}

public extension CollectionCellDescribable {
    
    func size(_ collectionViewBounds: CGRect, sectionDescriptor: CollectionSectionDescribable) -> CGSize {
        guard let layoutFitting = layoutFitting else {
            return CGSize(width: 0, height: 0)
        }
        let sectionInset = sectionDescriptor.sectionInset(collectionViewBounds)
        switch layoutFitting {
        case .estimatedHeight(let estimatedHeight):
            let width = collectionViewBounds.width - sectionInset.left - sectionInset.right
            return CGSize(width: width, height: estimatedHeight)
        case .fixedHeight(let height):
            let width = collectionViewBounds.width - sectionInset.left - sectionInset.right
            return CGSize(width: width, height: height)
        case .estimatedWidth(let estimatedWidth):
            let height = collectionViewBounds.height - sectionInset.top - sectionInset.bottom
            return CGSize(width: estimatedWidth, height: height)
        case .fixedWidth(let width):
            let height = collectionViewBounds.height - sectionInset.top - sectionInset.bottom
            return CGSize(width: width, height: height)
        case .fixed(let width, let height):
            return CGSize(width: width, height: height)
        }
    }
    
    func getAdapter() -> CollectionAdapter {
        return adapter
    }
}
extension CollectionCellDescribable {
    public internal(set) var indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.IndexPath) as? IndexPath
        }
        set {
            objc_setAssociatedObject( self, &AssociatedKeys.IndexPath, newValue as IndexPath?, .OBJC_ASSOCIATION_COPY)
        }
    }
}

