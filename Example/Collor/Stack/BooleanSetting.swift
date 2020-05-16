//
//  BooleanSetting.swift
//  Collor_Example
//
//  Created by Trendel Alexandre on 12/05/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Collor

protocol BooleanSettingAdapter {
    var isOn: Bool { get }
    var text: String { get }
}

struct MyBooleanSetting: BooleanSettingAdapter, Hashable, Diffable {
    let text: String
    let isOn: Bool
}

protocol BooleanSettingDelegate {
    func didChangeSetting(_: Bool)
}

final class BooleanSetting: UIView, Adaptable {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBAction func touchUpInside(_ sender: UISwitch) {
        self.delegate?.didChangeSetting(sender.isOn)
    }
    
    typealias Delegate = BooleanSettingDelegate
    
    static func create() -> BooleanSetting {
        Bundle(for: BooleanSetting.self)
            .loadNibNamed("\(BooleanSetting.self)", owner: self, options: nil)?
            .first as! BooleanSetting
    }
    
    func update(with adapter: BooleanSettingAdapter) {
        self.label.text = adapter.text
        self.switch.isOn = adapter.isOn
    }
}
