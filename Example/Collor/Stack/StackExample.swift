//
//  StackExample.swift
//  Collor_Example
//
//  Created by Trendel Alexandre on 12/05/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Collor

extension TweetCollectionViewCell: Adaptable {}
extension TweetDescriptor: Descriptor {}

class StackExample: UIViewController {
    
    var collection = AdaptableStackView()
    var isOn = false
    
    var tweet: TweetAdapter {
        TweetAdapter(tweet: Tweet(
            id: "6",
            text: "This is a Collor cell and desriptor, in a stack, in a (new) decoration view. Some update: isOn=\(self.isOn)",
            userProfileImageURL: "https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png",
            color: 0x2dde98,
            favoriteCount: 1,
            retweetCount: 1))
    }
    
    func reload() {
        collection.update(with: StackAdapter {
            AdaptableLabel.adapted(by: StackLabelAdapter(text: "First label"))
            
            StackDescriptor(MyDecoration(), innerMargin: 8) {
                TweetDescriptor(adapter: self.tweet)
            }
            
            BooleanSetting.adapted(by: MyBooleanSetting(text: "View more", isOn: self.isOn))
            
            If(self.isOn) {
                AdaptableLabel.adapted(by: StackLabelAdapter(text: "View more toggled!"))
            }
            
            exampleGroup()
            
        })
    }
    
    private func exampleGroup() -> GroupDescriptor {
        let labelDescriptor = AdaptableLabel.adapted
        return GroupDescriptor {
            labelDescriptor(StackLabelAdapter(text: "Some label"))
            labelDescriptor(StackLabelAdapter(text: "Some other label"))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        view.addSubview(collection.view)
        addChild(collection)
        
        NSLayoutConstraint.activate([
            collection.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collection.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collection.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8.0)
        ])
        
        self.reload()
    }

}

extension StackExample: BooleanSettingDelegate {
    func didChangeSetting(_ value: Bool) {
        self.isOn = value
        self.reload()
    }
    
}
