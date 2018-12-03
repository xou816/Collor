//
//  CollectionData.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import Collor

open class CollectionData: Collor.CollectionData {
    
    open override func reloadData() {
        super.reloadData()
    }
    
    public func addSection() -> SectionDescriptor {
        let sectionDescriptor = SectionDescriptor()
        sections.append(sectionDescriptor)
        return sectionDescriptor
    }
}
