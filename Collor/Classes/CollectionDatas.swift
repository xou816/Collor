//
//  CollectionData.swift
//  VSC
//
//  Created by Guihal Gwenn on 20/02/17.
//  Copyright (c) 2017-present, Voyages-sncf.com. All rights reserved.
//

import Foundation

open class CollectionData {
    
    public private(set) lazy var updater:CollectionUpdater = CollectionUpdater(collectionData: self)
    
    public init() {}
        
    public var sections = [CollectionSectionDescribable]()
    
    open func reloadData() {
        sections.removeAll()
    }
    
    //MARK: Internal
    
    var registeredCells = Set<String>()
    var registeredSupplementaryViews = Set<String>()
    
    public func sectionsCount() -> Int {
        return sections.count
    }
    
    //MARK: Update
    
    /**
     Computes indexPath for each CollectionCellDescribable and section index for each CollectionSectionDescribable.
     
     This method is called every time the collectionView calls 'numberOfSections' or during a data update (insertion or deletion) if needed.
     
     In most of cases, **this method doesn't have to be called manually**, call it only if you need to access to an indexPath before reloading the collectionView.
     */
    public func computeIndices() {
        for (sectionIndex, section) in sections.enumerated() {
            section.index = sectionIndex
            computeIndexPaths(in: section)
        }
    }
    
    public func computeIndexPaths(in section:CollectionSectionDescribable) {
        for (itemIndex, cell) in section.cells.enumerated() {
            cell.indexPath = IndexPath(item: itemIndex, section: section.index!)
        }
        section.supplementaryViews.forEach { (kind, views) in
            views.enumerated().forEach { (index, view) in
                view.indexPath = IndexPath(item: index, section: section.index!)
            }
        }
    }

    
    public func update(_ updates: (_ updater:CollectionUpdater) -> Void) -> UpdateCollectionResult {
        updater.result = UpdateCollectionResult()
        updates(updater)
        return updater.result!
    }
}

public extension CollectionData {
    
    func sectionDescribable(at indexPath: IndexPath) -> CollectionSectionDescribable? {
        return sections[safe: indexPath.section]
    }
    func sectionDescribable(for cellDescribable: CollectionCellDescribable) -> CollectionSectionDescribable? {
        return sections[safe: cellDescribable.indexPath?.section]
    }
    func cellDescribable(at indexPath: IndexPath) -> CollectionCellDescribable? {
        return sections[safe: indexPath.section]?.cells[indexPath.item]
    }
    func supplementaryViewDescribable(at indexPath: IndexPath, for kind: String) -> CollectionSupplementaryViewDescribable? {
        return sections[safe: indexPath.section]?.supplementaryViews[kind]?[indexPath.item]
    }
}

extension Collection {
    
    subscript (safe index: Index?) -> Iterator.Element? {
        guard let index = index else {
            return nil
        }
        return indices.contains(index) ? self[index] : nil
    }
}

