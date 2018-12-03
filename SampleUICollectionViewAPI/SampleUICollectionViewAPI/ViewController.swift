//
//  ViewController.swift
//  SampleUICollectionViewAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import UIKit
import Collor
import CollorAPI

class ViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate(set) lazy var collectionViewDelegate: CollectionDelegate = CollectionDelegate(delegate: self)
    fileprivate(set) lazy var collectionViewDatasource: CollectionDataSource = CollectionDataSource(delegate: self)
    
    let collectionData = SampleCollectionData()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(collectionView: collectionView, with: collectionData, and: collectionViewDelegate, and: collectionViewDatasource)
        collectionView.collectionViewLayout = VerticalCollectionViewLayout(collectionViewData: collectionData)
    }
}

extension ViewController : CollectionDidSelectCellDelegate {
    func didSelect(_ cellDescriptor: CollectionCellDescribable, sectionDescriptor: CollectionSectionDescribable, indexPath: IndexPath) {}
}

extension ViewController : CollectionUserEventDelegate {
    
}

