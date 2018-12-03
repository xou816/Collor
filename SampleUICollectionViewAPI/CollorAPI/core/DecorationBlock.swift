//
//  DecorationBlock.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import Collor

public enum DecorationBlockType {
    case whiteBordered
}

extension DecorationBlockType {
    func zIndex() -> Int {
        switch self {
        case .whiteBordered:
            return -1
        }
    }
    
    public func topPadding() -> CGFloat {
        switch self {
        case .whiteBordered:
            return 10
        }
    }
    
    public func bottomPadding() -> CGFloat {
        switch self {
        case .whiteBordered:
            return 10
        }
    }
}

public final class DecorationBlock {
    
    public let type: DecorationBlockType
    
    unowned var sectionDescriptor: CollectionSectionDescribable
    var startItemIndex: Int
    var endItemIndex: Int
    
    var firstIndexPath: IndexPath? {
        guard let sectionIndex = sectionDescriptor.index else {
            return nil
        }
        return IndexPath(item: startItemIndex, section: sectionIndex)
    }
    
    var endIndexPath: IndexPath? {
        guard let sectionIndex = sectionDescriptor.index else {
            return nil
        }
        return IndexPath(item: endItemIndex, section: sectionIndex)
    }
    
    init(type: DecorationBlockType, startItemIndex: Int, sectionDescriptor: CollectionSectionDescribable) {
        self.type = type
        self.startItemIndex = startItemIndex
        self.endItemIndex = startItemIndex
        self.sectionDescriptor = sectionDescriptor
    }
}
