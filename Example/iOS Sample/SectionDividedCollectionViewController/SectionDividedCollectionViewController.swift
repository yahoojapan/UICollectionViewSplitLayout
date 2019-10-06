
//
//  SectionDividedCollectionViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2018/10/06.
//  Copyright © 2018 Yahoo Japan Corporation. All rights reserved.
//

import UIKit
import UICollectionViewSplitLayout

class SectionDividedCollectionViewController: UICollectionViewController, UICollectionViewDelegateSectionSplitLayout {
    let layout = UICollectionViewSplitLayout()
    
    private let dataSource: [(headerColor: UIColor, footerColor: UIColor, elements: [(color: UIColor, size: CGSize)], decorationColor: UIColor)] = {
        let colors = (0..<10).map({ _ in UIColor.gray })
        let randomSizeHandler: () -> CGSize = { return CGSize(width: CGFloat.random(in: 50..<100), height: CGFloat.random(in: 50..<150)) }
        return [
            (headerColor: .red, footerColor: .blue, elements: (0..<10).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<20).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<30).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<40).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<50).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<60).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green),
            (headerColor: .red, footerColor: .blue, elements: (0..<70).map({ _ in (color: UIColor.lightGray, size: randomSizeHandler()) }), decorationColor: .green)
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        collectionView.collectionViewLayout = layout
        layout.minimumInterItemSpacing = 8
        layout.minimumItemLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.leftSideRatio = view.frame.width < view.frame.height ? 1 : 0.4
        layout.splitSpacing = 8
        if #available(iOS 11.0, *) {
            layout.sectionPinToVisibleBounds = true
        }
        collectionView.register(UINib(nibName: "SectionDividedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SectionDividedCollectionViewCell")
        collectionView.register(UINib(nibName: "SectionDividedSupplymentaryView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionDividedSupplymentaryView")
        collectionView.register(UINib(nibName: "SectionDividedSupplymentaryView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionDividedSupplymentaryView")
         
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        layout.leftSideRatio = size.width < size.height ? 1 : 0.4
        coordinator.animate(alongsideTransition: { [weak self] (_) in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataSource[section].elements.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionDividedCollectionViewCell", for: indexPath) as! SectionDividedCollectionViewCell
        cell.backgroundColor = dataSource[indexPath.section].elements[indexPath.item].color
        cell.titleLabel.text = "section \(indexPath.section): item \(indexPath.item)"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionDividedSupplymentaryView", for: indexPath) as! SectionDividedSupplymentaryView
        view.backgroundColor = kind == UICollectionView.elementKindSectionHeader ? dataSource[indexPath.section].headerColor : dataSource[indexPath.section].footerColor
        view.titleLabel.text = "section \(indexPath.section) \(kind == UICollectionView.elementKindSectionHeader ? "header" : "footer")"
        return view
    }

    // MARK: UICollectionViewDelegateSectionSplitLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        if let side = UICollectionViewSplitLayoutSide(leftSideRatio: layout.leftSideRatio) {
            return side
        }
        
        switch section {
        case 0, 2, 3, 5:
            return .left
        default:
            return .right
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        switch indexPath.section {
        case 0, 2, 4, 6:
            return dataSource[indexPath.section].elements[indexPath.row].size
        case 1, 5:
            return CGSize(width: layout.calculateFixedWidthRaughly(to: 2, of: side, minimumInterItemSpacing: layout.minimumInterItemSpacing, sectionInset: layout.sectionInset), height: 100)
        default:
            return CGSize(width: layout.calculateFixedWidthRaughly(to: 1, of: side, minimumInterItemSpacing: layout.minimumInterItemSpacing, sectionInset: layout.sectionInset), height: 44)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        return CGSize(width: layout.contentWidth(of: side), height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        return CGSize(width: layout.contentWidth(of: side), height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, itemsBackgroundColorFor section: Int, side: UICollectionViewSplitLayoutSide) -> UIColor? {
        return dataSource[section].decorationColor
    }
    
}
