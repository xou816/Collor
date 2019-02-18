//
//  Builder.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation
import Collor

public class Builder {
    private(set) unowned var sectionDescriptor: CollectionSectionDescribable
    public private(set) var cells = [CollectionCellDescribable]()
    private(set) var verticalSpaces = [Int: VerticalSpace]()
    private(set) var decorationBlocks = [DecorationBlock]()
    
    private var uncompleteDecorationBlocks = [DecorationBlock]()
    
    public init(sectionDescriptor: CollectionSectionDescribable) {
        self.sectionDescriptor = sectionDescriptor
    }
    
    public func add(verticalSpace: VerticalSpace) {
        let index = cells.indices.last ?? -1
        verticalSpaces[index] = verticalSpace
    }
    
    @discardableResult public func add(cell: CollectionCellDescribable) -> CollectionCellDescribable {
        cells.append(cell)
        return cell
    }
    
    @discardableResult public func add(label: LabelAdapterProtocol) -> CollectionCellDescribable {
        let cellDescriptor = LabelDescriptor(adapter: label)
        return add(cell: cellDescriptor)
    }
    
    @discardableResult public func add(link: LinkAdapterProtocol) -> CollectionCellDescribable {
        let cellDescriptor = LinkDescriptor(adapter: link)
        return add(cell: cellDescriptor)
    }
    
    @discardableResult public func add(separator adapter: LabelLineSeparatorAdapterProtocol) -> CollectionCellDescribable {
        let cellDescriptor = LabelLineSeparatorDescriptor(adapter: adapter)
        return add(cell: cellDescriptor)
    }
    
    public func startDecorationBlock(type: DecorationBlockType) -> DecorationBlock {
        let startindex = cells.indices.last.flatMap { $0 + 1 } ?? 0 // start the decorationView after the last cell
        let decorationBlock = DecorationBlock(type: type, startItemIndex: startindex, sectionDescriptor: sectionDescriptor)
        uncompleteDecorationBlocks.append(decorationBlock)
        return decorationBlock
    }
    
    public func addHorizontalLine() {
        let startindex = cells.indices.last.map { $0 + 1 } ?? 0 // start the decorationView after the last cell
        let block = DecorationBlock(type: .horizontalLine, startItemIndex: startindex, sectionDescriptor: sectionDescriptor)
        self.decorationBlocks.append(block)
    }
    
    public func endDecorationBlock(_ block: DecorationBlock?) {
        guard let block = block else {
            return
        }
        
        guard let lastIndex = cells.indices.last else {
            fatalError("End block in a no empty section")
        }
        // check if startItemIndex does exist
        guard cells.indices.contains(block.startItemIndex) else {
            fatalError("Add a cell after startDecorationBlock(:) and before calling endDecorationBlock()")
        }
        
        block.endItemIndex = lastIndex
        decorationBlocks.append(block)
        if let uncompleteIndex = uncompleteDecorationBlocks.index(where: { $0 === block }) {
            uncompleteDecorationBlocks.remove(at: uncompleteIndex)
        }
    }
}
