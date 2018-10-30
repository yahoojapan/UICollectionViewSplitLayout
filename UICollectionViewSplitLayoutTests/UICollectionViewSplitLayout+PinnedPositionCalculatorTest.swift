//
//  UICollectionViewSplitLayout+PinnedPositionCalculatorTest.swift
//  UICollectionViewSplitLayoutTests
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

import XCTest
@testable import UICollectionViewSplitLayout

class UICollectionViewSplitLayout_PinnedPositionCalculatorTest: XCTestCase {
    var layout: UICollectionViewSplitLayout!

    var pinnedPositionCalculator: UICollectionViewSplitLayout.PinnedPositionCalculator!
    var collectionVc: StubCollectionViewController!
    
    override func setUp() {
        layout = UICollectionViewSplitLayout()
        pinnedPositionCalculator = UICollectionViewSplitLayout.PinnedPositionCalculator()
        collectionVc = StubCollectionViewController(collectionViewLayout: layout)
        UIApplication.shared.keyWindow?.rootViewController = collectionVc
        collectionVc.collectionView.reloadData()
    }

    override func tearDown() {
        pinnedPositionCalculator = nil
    }

    func testExecuteToHeader() {
        collectionVc.collectionView.scrollToItem(at: IndexPath(item: 5, section: 0), at: .top, animated: false)
        let attrs = UICollectionViewSplitLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
        let point = pinnedPositionCalculator.execute(
            of: attrs,
            collectionViewLayout: layout
        )
        XCTAssertEqual(point, collectionVc.collectionView.contentOffset, "")
    }
    
    func testExecuteToItem() {
        collectionVc.collectionView.scrollToItem(at: IndexPath(item: 5, section: 0), at: .top, animated: false)
        let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
        let point = pinnedPositionCalculator.execute(
            of: attrs,
            collectionViewLayout: layout
        )
        XCTAssertNil(point, "")
    }
}

class StubCollectionViewController: UICollectionViewController, UICollectionViewDelegateSectionSplitLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        return .left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        return CGSize(width: width, height: 200)
    }
}
