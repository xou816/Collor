//
//  LineDecorationView.swift
//  VSC
//
//  Created by Guihal Gwenn on 29/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import UIKit

final class LineDecorationView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
}
