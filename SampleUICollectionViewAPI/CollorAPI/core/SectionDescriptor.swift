//
//  SectionDescriptor.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import Collor

public class SectionDescriptor: CollectionSectionDescribable {
    
    private var lineSpacing = VerticalSpace.zero
    private var horizontalInset: CGFloat = Inset.sectionDefault
    
    private(set) var verticalSpaces = [Int: VerticalSpace]()
    private(set) var decorationBlocks = [DecorationBlock]()
    
    public func lineSpacing(_ value: VerticalSpace) -> SectionDescriptor {
        lineSpacing = value
        return self
    }
    
    public func horizontalInset(_ value: Inset) -> SectionDescriptor {
        horizontalInset = value
        return self
    }
    
    public func sectionInset(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    public func minimumLineSpacing(_ collectionView: UICollectionView, layout: UICollectionViewFlowLayout) -> CGFloat {
        return lineSpacing
    }
    
    public typealias BuilderClosure = (Builder) -> Void
    
    @discardableResult public func reloadSection(_ builderClosure: @escaping BuilderClosure) -> SectionDescriptor {
        let builder = Builder(sectionDescriptor: self)
        builderClosure(builder)
        verticalSpaces = builder.verticalSpaces
        decorationBlocks = builder.decorationBlocks
        return reloadSection { cells in
            cells = builder.cells
        }
    }
}
