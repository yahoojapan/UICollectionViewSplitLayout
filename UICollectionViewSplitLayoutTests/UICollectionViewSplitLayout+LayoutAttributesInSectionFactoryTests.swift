//
//  UICollectionViewSplitLayout+LayoutAttributesInSectionFactoryTests.swift
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

class UICollectionViewSplitLayout_LayoutAttributesInSectionFactoryTests: XCTestCase {
    var layoutAttributesInSectionFactory: UICollectionViewSplitLayout.LayoutAttributesInSectionFactory!
    
    override func setUp() {
        layoutAttributesInSectionFactory = UICollectionViewSplitLayout.LayoutAttributesInSectionFactory()
    }

    override func tearDown() {
        layoutAttributesInSectionFactory = nil
    }

    func testMakeArbitorarySectionItems() {
        let firstPosition = CGPoint(x: 100, y: 100)
        let sectioninset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let minimumItemLineSpacing: CGFloat = 10
        let numberOfItems = 4
        var sizingHandlerCount: Int = 0
        let itemSize = CGSize(width: 90, height: 90)
        let attrsList = layoutAttributesInSectionFactory.makeItems(
            for: 1,
            side: .right,
            numberOfItems: numberOfItems,
            firstPosition: firstPosition,
            contentMostLeft: 100,
            contentWidth: 200,
            sectionInset: sectioninset,
            minimumInterItemSpacing: 10,
            minimumItemLineSpacing: minimumItemLineSpacing, isNormalizing: false,
            sizingHandler: { _ in
                sizingHandlerCount += 1
                return itemSize
            }
        )
        
        let expected: CGFloat = firstPosition.y +
            2 * itemSize.height +
            sectioninset.top +
            sectioninset.bottom +
            (minimumItemLineSpacing * 1)
        XCTAssertEqual(attrsList.lastPosition.y, expected, "")
        
        XCTAssertEqual(sizingHandlerCount, 4, "")
        
        let frames = attrsList.attributes.map { $0.frame }
        let expectedFrames = [
            CGRect(x: 105, y: 105, width: 90, height: 90),
            CGRect(x: 205, y: 105, width: 90, height: 90),
            CGRect(x: 105, y: 205, width: 90, height: 90),
            CGRect(x: 205, y: 205, width: 90, height: 90)
        ]
        XCTAssertEqual(frames, expectedFrames, "")
        
        let indexPathes = attrsList.attributes.map { $0.indexPath }
        let expectedIndexPathes = [
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1),
            IndexPath(item: 2, section: 1),
            IndexPath(item: 3, section: 1)
        ]
        XCTAssertEqual(indexPathes, expectedIndexPathes, "")
        
        let sides = attrsList.attributes.map { $0.side }
        let expectedSides = Array(repeating: UICollectionViewSplitLayoutSide.right, count: 4)
        XCTAssertEqual(sides, expectedSides, "")
        
        let sectionInsets = attrsList.attributes.map { $0.sectionInset }
        let expectedSectionInsets = Array(repeating: sectioninset, count: 4)
        XCTAssertEqual(sectionInsets, expectedSectionInsets, "")
        
        let minimumItemLineSpacings = attrsList.attributes.map { $0.minimumItemLineSpacing }
        let expectedMinimumItemLineSpacing = Array(repeating: minimumItemLineSpacing, count: 4)
        XCTAssertEqual(minimumItemLineSpacings, expectedMinimumItemLineSpacing, "")
    }

    func testMakeHeader() {
        let firstPosition = CGPoint(x: 100, y: 100)
        let sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let minimumItemLineSpacing: CGFloat = 10
        let headerSize = CGSize(width: 100, height: 90)
        let attrs = layoutAttributesInSectionFactory.makeHeader(
            at: 1,
            nextPosition: firstPosition,
            side: .right,
            sectionInset: sectionInset,
            minimumItemLineSpacing: minimumItemLineSpacing,
            headerSize: headerSize
        )
        let frame = CGRect(x: 100, y: 100, width: 100, height: 90)
        XCTAssertEqual(attrs?.frame, frame, "")
        
        let indexPath = IndexPath(item: 0, section: 1)
        XCTAssertEqual(attrs?.indexPath, indexPath, "")

        XCTAssertEqual(attrs?.sectionInset, sectionInset, "")
        XCTAssertEqual(attrs?.minimumItemLineSpacing, minimumItemLineSpacing, "")
        XCTAssertEqual(attrs?.side, .right, "")
    }
    
    func testMakeFooter() {
        let firstPosition = CGPoint(x: 100, y: 100)
        let sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let minimumItemLineSpacing: CGFloat = 10
        let footerSize = CGSize(width: 100, height: 90)
        let attrs = layoutAttributesInSectionFactory.makeFooter(
            at: 1,
            nextPosition: firstPosition,
            side: .right,
            sectionInset: sectionInset,
            minimumItemLineSpacing: minimumItemLineSpacing,
            footerSize: footerSize
        )
        let frame = CGRect(x: 100, y: 100, width: 100, height: 90)
        XCTAssertEqual(attrs?.frame, frame, "")
        
        let indexPath = IndexPath(item: 0, section: 1)
        XCTAssertEqual(attrs?.indexPath, indexPath, "")
        
        XCTAssertEqual(attrs?.sectionInset, sectionInset, "")
        XCTAssertEqual(attrs?.minimumItemLineSpacing, minimumItemLineSpacing, "")
        XCTAssertEqual(attrs?.side, .right, "")
    }
}
