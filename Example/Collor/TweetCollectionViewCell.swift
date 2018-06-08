//
//  TweetCollectionViewCell.swift
//  Collor
//
//  Created by Guihal Gwenn on 05/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Collor
import AlamofireImage

final class TweetCollectionViewCell: UICollectionViewCell, CollectionCellAdaptable {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.af_cancelImageRequest()
    }
    
    func update(with adapter: CollectionAdapter) {
        guard let adapter = adapter as? TweetAdapter else {
            fatalError("TweetAdapter required")
        }
        
        label.attributedText = adapter.label
        imageView.af_setImage(withURL: adapter.imageURL)
    }
}

final class TweetDescriptor: CollectionCellDescribable {
    
    let identifier: String = "TweetCollectionViewCell"
    let className: String = "TweetCollectionViewCell"
    var selectable:Bool = false
    var adapter: CollectionAdapter
    var layoutFitting: LayoutFitting? = .estimatedHeight(estimatedHeight: 100)
    
    init(adapter:TweetAdapter) {
        self.adapter = adapter
    }
    
//    func size(_ collectionViewBounds:CGRect, sectionDescriptor: CollectionSectionDescribable) -> CGSize {
//        guard let adapter = adapter as? TweetAdapter else {
//            fatalError("TweetAdapter required")
//        }
//        let sectionInset = sectionDescriptor.sectionInset(collectionViewBounds)
//        let width:CGFloat = collectionViewBounds.width - sectionInset.left - sectionInset.right
//        let labelWidth = width - 48 - 4 // cf xib
////        let cellHeight = max(48, adapter.label.height(labelWidth))
//        let cellHeight = adapter.label.height(labelWidth)
//        print(indexPath!,cellHeight)
//        return CGSize(width:width, height:cellHeight)
//    }
}
