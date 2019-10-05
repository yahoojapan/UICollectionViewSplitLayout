//
//  BasicCollectionViewController.swift
//  iOS Sample
//
//  Copyright (c) 2018 Yahoo Japan Corporation.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import UICollectionViewSplitLayout

private let reuseIdentifier = "Cell"

class BasicCollectionViewController: UICollectionViewController {
    @IBOutlet weak var layout: UICollectionViewSplitLayout!
    
    var dataSource: [[UIColor]] = [
        (0..<20).map { _ in .red },
        (0..<20).map {  _ in .blue },
        (0..<20).map {  _ in .green }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.minimumItemLineSpacing = 8
        layout.minimumInterItemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.leftSideRatio = 0.4
        collectionView.collectionViewLayout = layout

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = dataSource[indexPath.section][indexPath.row]
        return cell
    }
}

extension BasicCollectionViewController: UICollectionViewDelegateSectionSplitLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        let width = layout.calculateFixedWidthRaughly(
            to: 3,
            of: side,
            minimumInterItemSpacing: layout.minimumInterItemSpacing,
            sectionInset: layout.sectionInset)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        if let side = UICollectionViewSplitLayoutSide(leftSideRatio: layout.leftSideRatio) {
            return side
        }
        
        return section % 2 == 0 ? .left : .right
    }
}

