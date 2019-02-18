//
//  SampleCollectionData.swift
//  SampleUICollectionViewAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import Collor
import CollorAPI
import SwiftyAttributes

final class SampleCollectionData: CollorAPI.CollectionData {
    override func reloadData() {
        super.reloadData()
        
        addSection().reloadSection { builder in
            builder.add(separator: Adapters.TitleAAdapter())
            builder.add(verticalSpace: .medium)
            builder.add(label: Adapters.LoremIpsumAdapter())
            
            builder.add(verticalSpace: .huge)
        }
        
        addSection().reloadSection { builder in
            builder.add(verticalSpace: .medium)
            builder.addHorizontalLine()
            builder.add(link: Adapters.PlugAdapter())
            builder.addHorizontalLine()
            builder.add(link: Adapters.QuietAdapter())
            builder.addHorizontalLine()
            builder.add(label: Adapters.LinksDescriptionAdapter())
            
            builder.add(verticalSpace: .huge)
        }
        
        addSection().horizontalInset(.big).reloadSection { builder in
            let block = builder.startDecorationBlock(type: .whiteBordered)
            builder.add(separator: Adapters.TitleCAdapter())
            builder.add(verticalSpace: .medium)
            builder.add(label: Adapters.LoremIpsumWhiteAdapter())
            builder.endDecorationBlock(block)
            
            builder.add(verticalSpace: .huge)
        }
        
        addSection().horizontalInset(.huge).reloadSection { builder in
            builder.add(separator: Adapters.TitleBAdapter())
            builder.add(verticalSpace: .medium)
            builder.add(label: Adapters.LoremIpsumAdapter())
            
            builder.add(verticalSpace: .huge)
        }
        
        
    }
}

extension SampleCollectionData {
    struct Adapters {
        
        struct TitleAAdapter: LabelLineSeparatorAdapterProtocol {
            var label: String = "Title A"
        }
        
        struct TitleBAdapter: LabelLineSeparatorAdapterProtocol {
            var label: String = "Title B"
        }
        
        struct TitleCAdapter: LabelLineSeparatorAdapterProtocol {
            var label: String = "Title C"
        }
        
        struct LoremIpsumAdapter: LabelAdapterProtocol {
            static var loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tempus velit suscipit mauris aliquet egestas. Cras et urna nunc. Quisque ornare fermentum erat, sit amet condimentum diam pulvinar vel. Vestibulum aliquet nulla nisl, ac pellentesque ante viverra eget. Nullam at sodales sem, in semper turpis. Cras laoreet augue felis, ut egestas nunc tempor id. Sed et scelerisque sem, at consequat orci. Mauris hendrerit eros ac eros commodo, ut viverra nisi porta."

            var label: NSAttributedString = loremIpsum.withFont(.systemFont(ofSize: 14))
        }
        
        struct LoremIpsumWhiteAdapter: LabelAdapterProtocol {
            static var loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tempus velit suscipit mauris aliquet egestas. Cras et urna nunc. Quisque ornare fermentum erat, sit amet condimentum diam pulvinar vel. Vestibulum aliquet nulla nisl, ac pellentesque ante viverra eget. Nullam at sodales sem, in semper turpis. Cras laoreet augue felis, ut egestas nunc tempor id. Sed et scelerisque sem, at consequat orci. Mauris hendrerit eros ac eros commodo, ut viverra nisi porta."
            
            var label: NSAttributedString = loremIpsum.withFont(.systemFont(ofSize: 12)).withTextColor(.black)
        }
        
        struct PlugAdapter: LinkAdapterProtocol {
            var label: String = "Plug link"
            var image: UIImage = UIImage(named: "plug")!
        }
        
        struct QuietAdapter: LinkAdapterProtocol {
            var label: String = "Quiet Link"
            var image: UIImage = UIImage(named: "quiet")!
        }
        
        struct LinksDescriptionAdapter: LabelAdapterProtocol {
            var label: NSAttributedString = "In tempus velit suscipit mauris aliquet egestas."
                .withFont(.systemFont(ofSize: 12))
                .withTextColor(.lightGray)
                .withParagraphStyle(.center)
        }
    }
}

extension ParagraphStyle {
    static var center: ParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
}
