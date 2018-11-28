//
//  LabelCollectionViewCell.swift
//  VSC
//
//  Created by Guihal Gwenn on 23/02/2018.
//  Copyright © 2018 VSCT. All rights reserved.
//

import UIKit
import Collor
import Foundation

public final class LabelCollectionViewCell: UICollectionViewCell, CollectionCellAdaptable {

    @IBOutlet weak var label: UILabel!
    
    public func update(with adapter: CollectionAdapter) {
        guard let adapter = adapter as? LabelAdapterProtocol else {
            fatalError("LabelAdapterProtocol required")
        }
        label.attributedText = adapter.label
    }
}

public protocol LabelAdapterProtocol: CollectionAdapter {
    var label: NSAttributedString { get }
    var clickable: Bool { get }
}

public extension LabelAdapterProtocol {
    var clickable: Bool { return false }
}

public final class LabelDescriptor: CollectionCellDescribable {
    
    public let className: String = "LabelCollectionViewCell"
    lazy public var identifier: String = className
    public var selectable: Bool = false
    
    let adapter: LabelAdapterProtocol
    
    public init(adapter: LabelAdapterProtocol) {
        self.adapter = adapter
        self.selectable = adapter.clickable
    }
    
    public func size(_ collectionView: UICollectionView, sectionDescriptor: CollectionSectionDescribable) -> CGSize {
        let sectionInset = sectionDescriptor.sectionInset(collectionView)
        let width:CGFloat = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return CGSize(width:width, height: adapter.label.height(width))
    }
    
    public func getAdapter() -> CollectionAdapter {
        return adapter
    }
}

extension NSAttributedString {
    func height(_ forWidth: CGFloat) -> CGFloat {
        let size = self.boundingRect(with: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [NSStringDrawingOptions.usesLineFragmentOrigin , NSStringDrawingOptions.usesFontLeading],
                                     context: nil)
        
        return ceil(size.height)
    }
}
