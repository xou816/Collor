//
//  VerticalCollectionViewLayout.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import UIKit
import Collor

open class VerticalCollectionViewLayout: UICollectionViewFlowLayout {
    
    unowned fileprivate let collectionViewData: CollectionData
    
    fileprivate lazy var decorationViewHandler: DecorationViewsHandler = DecorationViewsHandler(collectionViewLayout: self)
    
    fileprivate var cachedItemAttributes = [IndexPath:UICollectionViewLayoutAttributes]()
    fileprivate var globalOffset = CGPoint()
    var contentSize = CGSize()
    
    private enum Kind: String {
        case whiteBordered
        case line
    }
    
    
    public init(collectionViewData: CollectionData) {
        self.collectionViewData = collectionViewData
        super.init()
        
        decorationViewHandler.register(viewClass: WhiteBorderedDecorationView.self, for: Kind.whiteBordered.rawValue)
        decorationViewHandler.register(viewClass: LineDecorationView.self, for: Kind.line.rawValue)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, scrollDirection == .vertical else {
            return
        }
        
        collectionViewData.computeIndices()
        
        decorationViewHandler.prepare()
        
        // reset
        globalOffset = CGPoint()
        cachedItemAttributes.removeAll()
        
        let decorationBlocks = collectionViewData.sections.compactMap { $0 as? SectionDescriptor }.flatMap { $0.decorationBlocks }
        
        collectionViewData.sections.enumerated().forEach { (sectionIndex, sectionDescriptor) in
            
            // cast SectionDescriptor
            guard let sectionDescriptor = collectionViewData.sections[sectionIndex] as? SectionDescriptor else {
                return
            }
            
            sectionDescriptor.cells.compactMap { $0.indexPath }.forEach { indexPath in
                
                // copy super itemAttributes
                guard let itemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
                    return
                }
                
                // block top padding ?
                let topDecorationBlocks = decorationBlocks.filter { $0.firstIndexPath == indexPath }
                let topPadding = topDecorationBlocks.reduce(0, { $0 + $1.type.topPadding() })
                globalOffset.y += topPadding
                
                itemAttributes.frame = itemAttributes.frame.offsetBy(dx: 0, dy: globalOffset.y)
                cachedItemAttributes[indexPath] = itemAttributes
                
                // block bottom padding ?
                let bottomDecorationBlocks = decorationBlocks.filter { $0.endIndexPath == indexPath }
                let bottomPadding = bottomDecorationBlocks.reduce(0, { $0 + $1.type.bottomPadding() })
                globalOffset.y += bottomPadding
                
                // vertical spaces
                if let verticalSpace = sectionDescriptor.verticalSpaces[indexPath.item] {
                    globalOffset.y += verticalSpace
                }
            }
        }
        
        decorationBlocks.forEach { decorationBlock in
            
            guard let firstIndexPath = decorationBlock.firstIndexPath, let endIndexPath = decorationBlock.endIndexPath else {
                return
            }
            guard let firstCellAttributes = layoutAttributesForItem(at: firstIndexPath), let endCellAttributes = layoutAttributesForItem(at: endIndexPath) else {
                return
            }
            
            switch decorationBlock.type {
            case .whiteBordered:
                addWhiteBorderedDecoration(decorationBlock: decorationBlock,
                                   firstIndexPath: firstIndexPath, endIndexPath: endIndexPath,
                                   firstCellAttributes: firstCellAttributes, endCellAttributes: endCellAttributes,
                                   in: collectionView)
            case .horizontalLine:
                addLineDecoration(decorationBlock: decorationBlock,
                                  indexPath: firstIndexPath,
                                  cellAttributes: firstCellAttributes,
                                  in: collectionView)
            }
        }
        
        // content Size
        contentSize = super.collectionViewContentSize
        contentSize.height += globalOffset.y
    }
    
    private func addWhiteBorderedDecoration(decorationBlock: DecorationBlock,
                                    firstIndexPath: IndexPath, endIndexPath: IndexPath,
                                    firstCellAttributes: UICollectionViewLayoutAttributes, endCellAttributes: UICollectionViewLayoutAttributes,
                                    in collectionView: UICollectionView) {
        
        let decorationAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: Kind.whiteBordered.rawValue, with: firstIndexPath)
        
        let offsetX: CGFloat = 10
        
        let origin = CGPoint(x: offsetX,
                             y: firstCellAttributes.frame.origin.y - decorationBlock.type.topPadding())
        let width = collectionView.frame.width - 2 * offsetX
        let height = endCellAttributes.frame.maxY - origin.y + decorationBlock.type.bottomPadding()
        
        decorationAttributes.zIndex = decorationBlock.type.zIndex()
        decorationAttributes.frame = CGRect(x: origin.x,
                                            y: origin.y,
                                            width: width,
                                            height: height)
        
        decorationViewHandler.add(attributes: decorationAttributes)
    }
    
    private func addLineDecoration(decorationBlock: DecorationBlock,
                                   indexPath: IndexPath,
                                   cellAttributes: UICollectionViewLayoutAttributes,
                                   in collectionView: UICollectionView) {
        
        let decorationAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: Kind.line.rawValue,
                                                                    with: indexPath)
        let offsetX: CGFloat = 10
        let origin = CGPoint(x: offsetX,
                             y: cellAttributes.frame.origin.y - decorationBlock.type.topPadding() )
        let width = collectionView.frame.width - 2 * offsetX
        let height: CGFloat = 1
        
        decorationAttributes.zIndex = decorationBlock.type.zIndex()
        decorationAttributes.frame = CGRect(x: origin.x,
                                            y: origin.y,
                                            width: width,
                                            height: height)
        
        decorationViewHandler.add(attributes: decorationAttributes)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedItemAttributes[indexPath]
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = cachedItemAttributes.values.filter { rect.intersects($0.frame) }
        let decorationAttributes = decorationViewHandler.attributes(in:rect)
        return attributes + decorationAttributes
    }
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at atIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return decorationViewHandler.attributes(for: elementKind, at: atIndexPath)
    }
    
    override open func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        decorationViewHandler.prepare(forCollectionViewUpdates: updateItems)
    }
    
    override open func indexPathsToInsertForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return decorationViewHandler.inserted(for: elementKind)
    }
    
    override open func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return decorationViewHandler.deleted(for: elementKind)
    }
}
