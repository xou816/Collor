//
//  LabelLineSeparatorCollectionViewCell.swift
//  Pods
//
//  Created by Guihal Gwenn on 31/05/2018.
//  
//

import UIKit
import Collor
import SwiftyAttributes

public final class LabelLineSeparatorCollectionViewCell: UICollectionViewCell, CollectionCellAdaptable {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        leftLine.backgroundColor = .white
        rightLine.backgroundColor = .white
    }
    
    public func update(with adapter: CollectionAdapter) {
        guard let adapter = adapter as? LabelLineSeparatorAdapterProtocol else {
            fatalError("LabelLineSeparatorAdapterProtocol required")
        }
        label.attributedText = adapter.label.withFont(.boldSystemFont(ofSize: 16)).withTextColor(adapter.color)
        leftLine.backgroundColor = adapter.color
        rightLine.backgroundColor = adapter.color
    }

}

public protocol LabelLineSeparatorAdapterProtocol: CollectionAdapter {
    var label: String { get }
    var color: UIColor { get }
}

public final class LabelLineSeparatorDescriptor: CollectionCellDescribable {
    
    public let className: String = "LabelLineSeparatorCollectionViewCell"
    lazy public var identifier: String = className
    public var selectable: Bool = false
    var height: CGFloat = 20
    
    let adapter: LabelLineSeparatorAdapterProtocol
    
    public init(adapter: LabelLineSeparatorAdapterProtocol) {
        self.adapter = adapter
    }
    
    public func getAdapter() -> CollectionAdapter {
        return adapter
    }
    
    public func size(_ collectionView: UICollectionView, sectionDescriptor: CollectionSectionDescribable) -> CGSize {
        let sectionInset = sectionDescriptor.sectionInset(collectionView)
        let width:CGFloat = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return CGSize(width:width, height: height)
    }
}
