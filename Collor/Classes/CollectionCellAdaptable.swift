//
//  CollectionCellAdaptable.swift
//  Collor
//
//  Created by Guihal Gwenn on 16/03/17.
//  Copyright (c) 2017-present, Voyages-sncf.com. All rights reserved.
//

import Foundation

private struct AssociatedKeys {
    static var CollectionCellDescribable = "collor_CollectionCellDescribable"
}

public protocol CollectionCellAdaptable : NSObjectProtocol {
    func update(with adapter: CollectionAdapter) -> Void
    func set(delegate:CollectionUserEventDelegate?) -> Void
}

// default implementation of CollectionCellAdaptable
public extension CollectionCellAdaptable {
    func set(delegate:CollectionUserEventDelegate?) {}
}

extension CollectionCellAdaptable {
    public internal(set) var descriptor: CollectionCellDescribable? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.CollectionCellDescribable) as? CollectionCellDescribable
        }
        set {
            objc_setAssociatedObject( self, &AssociatedKeys.CollectionCellDescribable, newValue as CollectionCellDescribable?, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
