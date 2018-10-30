//
//  UICollectionViewSplitLayoutTests.swift
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

class UICollectionViewSplitLayoutTests: XCTestCase {
    private var vc: SpyCollectionViewController!
    var layout: UICollectionViewSplitLayout!
    
    override func setUp() {
        layout = UICollectionViewSplitLayout()
        vc = SpyCollectionViewController(collectionViewLayout: layout)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    override func tearDown() {
        layout = nil
        vc = nil
        UIApplication.shared.keyWindow?.rootViewController = nil
    }
    
    func testInvalidateLayout() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        let expected = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: 0),
            CGPoint(x: 200, y: 0),
            CGPoint(x: 0, y: 100),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 100),
            CGPoint(x: 300, y: 100),
            CGPoint(x: 0, y: 200),
            CGPoint(x: 0, y: 300),
            CGPoint(x: 100, y: 300),
            CGPoint(x: 200, y: 300)
        ]
        let actual = [
            IndexPath(item: 0, section: 0),
            IndexPath(item: 1, section: 0),
            IndexPath(item: 2, section: 0),
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1),
            IndexPath(item: 2, section: 1),
            IndexPath(item: 3, section: 1),
            IndexPath(item: 4, section: 1),
            IndexPath(item: 0, section: 2),
            IndexPath(item: 1, section: 2),
            IndexPath(item: 2, section: 2)
        ].compactMap { layout.layoutAttributesForItem(at: $0)?.frame.origin }
        XCTAssertEqual(actual, expected, "")
    }
    
    func testLayoutAttributesForElements() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        let actual = layout.layoutAttributesForElements(in: CGRect(x: 0, y: 100, width: 400, height: 100))?
            .compactMap { $0.indexPath }
        let expected = [
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1),
            IndexPath(item: 2, section: 1),
            IndexPath(item: 3, section: 1),
            IndexPath(item: 0, section: 1)
        ]
        XCTAssertEqual(actual, expected, "")
    }
    
    func testLayoutAttributesForItem() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        let actual = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        let expected = CGRect(x: 0, y: 100, width: 100, height: 100)
        XCTAssertEqual(actual?.frame, expected, "")
    }
    
    func testLayoutAttributesForDecorationView() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        let actual = layout.layoutAttributesForDecorationView(ofKind: UICollectionViewSplitLayoutBackgroundView.className, at: IndexPath(item: 0, section: 1))?.frame
        let expected = CGRect(x: 0, y: 100, width: 400, height: 200)
        XCTAssertEqual(actual, expected, "")
    }
    
    func testCollectionViewContentSize() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        let actual = layout.collectionViewContentSize
        let expected = CGSize(width: 400, height: 400)
        XCTAssertEqual(actual, expected, "")
    }
    
    func testOnyRecalculateWhenIsInvalidationBoundsChageTrue() {
        vc.collectionView.frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        vc.dataSource = [[0, 1, 2], [0, 1, 2, 3, 4, 5], [0, 1, 2]]
        layout.leftSideRatio = 1
        vc.collectionView.reloadData()
        vc.collectionView.scrollRectToVisible(CGRect(x: 0, y: 100, width: 400, height: 300), animated: false)
        XCTAssertEqual(vc.sizeCallCount, 12, "")
        
        vc.collectionView.collectionViewLayout.invalidateLayout()
        XCTAssertEqual(vc.sizeCallCount, 24, "")
    }
}

private let reuseIdentifier = "Cell"

private class SpyCollectionViewController: UICollectionViewController, UICollectionViewDelegateSectionSplitLayout {
    var dataSource: [[Int]] = []
    var sizeCallCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        sizeCallCount += 1
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        return .left
    }
}
