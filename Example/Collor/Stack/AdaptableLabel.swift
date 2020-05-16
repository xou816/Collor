//
//  AdaptableLabel.swift
//  Collor_Example
//
//  Created by Trendel Alexandre on 12/05/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreGraphics
import Collor

protocol StackLabelAdapterProtocol {
    var text: String { get }
}

struct StackLabelAdapter: StackLabelAdapterProtocol, Hashable, Diffable {
    public let text: String
}

final class AdaptableLabel: UIView, Adaptable {
    
    static func create() -> AdaptableLabel {
        return AdaptableLabel()
    }
    
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.sizeToFit()
    }
    
    func update(with adapter: StackLabelAdapterProtocol) {
        label.text = adapter.text
        label.sizeToFit()
    }
    
    override var intrinsicContentSize: CGSize {
        label.frame.size
    }
}

class MyDecoration: UIView {
    
    override public func layoutSubviews() {
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        layer.backgroundColor = UIColor.white.cgColor
    }
}
