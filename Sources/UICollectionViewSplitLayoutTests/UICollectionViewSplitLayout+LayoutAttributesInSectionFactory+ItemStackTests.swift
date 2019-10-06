//
//  UICollectionViewSplitLayout+LayoutAttributesInSectionFactory+ItemStackTests.swift
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

class UICollectionViewSplitLayout_LayoutAttributesInSectionFactory_ItemStackNoneNormalizingTests: XCTestCase {
    var itemCoumnStack: UICollectionViewSplitLayout.LayoutAttributesInSectionFactory.ItemColumnStack!
    override func setUp() {
        itemCoumnStack = UICollectionViewSplitLayout.LayoutAttributesInSectionFactory.ItemColumnStack(isNormalizing: false)
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            itemCoumnStack.append(attrs: attrs)
        }
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
            itemCoumnStack.append(attrs: attrs)
        }
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 300)
            itemCoumnStack.append(attrs: attrs)
        }
    }

    override func tearDown() {
        itemCoumnStack = nil
    }
    
    func testAppend() {
        XCTAssertEqual(itemCoumnStack.refinedAttrs.count, 3, "")
    }
    
    func testReset() {
        itemCoumnStack.reset()
        XCTAssertEqual(itemCoumnStack.refinedAttrs.count, 0, "")
    }
    
    func testMaxHeight() {
        XCTAssertEqual(itemCoumnStack.maxHeight, 300, "")
    }
    
    func testNormalizedAttrs() {
        XCTAssertEqual(
            itemCoumnStack.refinedAttrs.map { $0.size },
            [
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 200),
                CGSize(width: 100, height: 300)
            ], "")
    }
}

class UICollectionViewSplitLayout_LayoutAttributesInSectionFactory_ItemStackNormalizingTests: XCTestCase {
    var itemCoumnStack: UICollectionViewSplitLayout.LayoutAttributesInSectionFactory.ItemColumnStack!
    override func setUp() {
        itemCoumnStack = UICollectionViewSplitLayout.LayoutAttributesInSectionFactory.ItemColumnStack(isNormalizing: true)
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            itemCoumnStack.append(attrs: attrs)
        }
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
            itemCoumnStack.append(attrs: attrs)
        }
        do {
            let attrs = UICollectionViewSplitLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            attrs.frame = CGRect(x: 0, y: 0, width: 100, height: 300)
            itemCoumnStack.append(attrs: attrs)
        }
    }
    
    override func tearDown() {
        itemCoumnStack = nil
    }
    
    func testAppend() {
        XCTAssertEqual(itemCoumnStack.refinedAttrs.count, 3, "")
    }
    
    func testReset() {
        itemCoumnStack.reset()
        XCTAssertEqual(itemCoumnStack.refinedAttrs.count, 0, "")
    }
    
    func testMaxHeight() {
        XCTAssertEqual(itemCoumnStack.maxHeight, 300, "")
    }
    
    func testNormalizedAttrs() {
        XCTAssertEqual(
            itemCoumnStack.refinedAttrs.map { $0.size },
            [
                CGSize(width: 100, height: 300),
                CGSize(width: 100, height: 300),
                CGSize(width: 100, height: 300)
            ], "")
    }
}
