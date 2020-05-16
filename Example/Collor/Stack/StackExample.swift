//
//  StackExample.swift
//  Collor_Example
//
//  Created by Trendel Alexandre on 12/05/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Collor

extension TweetCollectionViewCell: Adaptable {
    
    static func create() -> TweetCollectionViewCell {
        Bundle(for: TweetCollectionViewCell.self)
            .loadNibNamed("\(TweetCollectionViewCell.self)", owner: self, options: nil)?
            .first as! TweetCollectionViewCell
    }
}

class StackExample: UIViewController {
    
    var collection = AdaptableStackView()
    var isOn = false
    
    let tweet = TweetAdapter(tweet: Tweet(
        id: "6",
        text: "Nam turpis tellus, commodo quis odio sit amet, aliquam posuere nulla.",
        userProfileImageURL: "https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png",
        color: 0x2dde98,
        favoriteCount: 1,
        retweetCount: 1))
    
    func reload() {
        collection.update(with: StackAdapter {
            AdaptableLabel.adapted(by: StackLabelAdapter(text: "First label"))
            
            Decoration(MyDecoration(), innerMargin: 8) {
                AdaptableLabel.adapted(by: StackLabelAdapter(text: "A Collor cell :"))
                TweetCollectionViewCell.adapted(by: self.tweet)
                AdaptableLabel.adapted(by: StackLabelAdapter(text: "isOn = \(self.isOn)"))
            }
            
            BooleanSetting.adapted(by: MyBooleanSetting(text: "View more", isOn: self.isOn))
            
            If(self.isOn) {
                AdaptableLabel.adapted(by: StackLabelAdapter(text: "Some label 1"))
                AdaptableLabel.adapted(by: StackLabelAdapter(text: "Some label 2"))
            }
            
            exampleSection()
            
        })
    }
    
    private func exampleSection() -> Section {
        Section {
            AdaptableLabel.adapted(by: StackLabelAdapter(text: "Some label 3"))
            AdaptableLabel.adapted(by: StackLabelAdapter(text: "Some label 4"))
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
