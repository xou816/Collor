//
//  LinkCollectionViewCell.swift
//  SampleUICollectionViewAPI
//
//  Created by Guihal Gwenn on 18/02/2019.
//  Copyright © 2019 oui.sncf. All rights reserved.
//

import UIKit
import Collor
import SwiftyAttributes

public final class LinkCollectionViewCell: UICollectionViewCell, CollectionCellAdaptable {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func update(with adapter: CollectionAdapter) {
        guard let adapter = adapter as? LinkAdapterProtocol else {
            fatalError("LinkAdapterProtocol required")
        }
        label.attributedText = adapter.label
            .withFont(.systemFont(ofSize: 14, weight: UIFont.Weight.medium))
            .withTextColor(.darkText)
        imageView.image = adapter.image
    }

}

public protocol LinkAdapterProtocol: CollectionAdapter {
    var image: UIImage { get }
    var label: String { get }
}

public final class LinkDescriptor: CollectionCellDescribable {
    
    public let identifier: String = "LinkCollectionViewCell"
    public let className: String = "LinkCollectionViewCell"
    public var selectable: Bool = false
    let height: CGFloat = 40
    
    let adapter: LinkAdapterProtocol
    
    public init(adapter: LinkAdapterProtocol) {
        self.adapter = adapter
    }
    
    public func size(_ collectionView: UICollectionView, sectionDescriptor: CollectionSectionDescribable) -> CGSize {
        let sectionInset = sectionDescriptor.sectionInset(collectionView)
        let width: CGFloat = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return CGSize(width: width, height: height)
    }
    
    public func getAdapter() -> CollectionAdapter {
        return adapter
    }
}
