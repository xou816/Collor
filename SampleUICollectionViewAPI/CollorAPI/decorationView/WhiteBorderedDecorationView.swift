//
//  WhiteBorderedDecorationView.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 29/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import UIKit

final class WhiteBorderedDecorationView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
