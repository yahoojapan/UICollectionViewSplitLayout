//
//  UICollectionViewSplitLayout+PinnedLayoutManager.swift
//  UICollectionViewSplitLayout
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

extension UICollectionViewSplitLayout {
    /// calculates floating point for supplymentaly view
    /// - parameter attrs: suppulymentaly view attributes
    /// - returns: floating point for supplymentaly view
    class PinnedPositionCalculator {
        @available(iOS 11.0, *)
        func execute(
            of attrs: UICollectionViewSplitLayoutAttributes,
            collectionViewLayout: UICollectionViewSplitLayout) -> CGPoint? {
            
            guard let collectionView = collectionViewLayout.collectionView else { return nil }
            
            guard attrs.representedElementKind == UICollectionView.elementKindSectionHeader
                || attrs.representedElementKind == UICollectionView.elementKindSectionFooter else { return nil }
            
            let section = attrs.indexPath.section
            let numberOfItem = collectionView.numberOfItems(inSection: section)
            
            let firstIndexPath = IndexPath(item: 0, section: section)
            let lastIndexPath = IndexPath(item: max(0, (numberOfItem - 1)), section: section)
            
            var origin = attrs.frame.origin
            
            let headerHeight: CGFloat
            let footerHeight: CGFloat
            if numberOfItem == 0 {
                let topHeaderHeight = CGFloat(0)
                let firstAttrs = collectionViewLayout.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader, at: firstIndexPath
                )
                headerHeight = (firstAttrs?.frame.minY ?? 0) - topHeaderHeight - attrs.sectionInset.top
                
                let bottomHeaderHeight = attrs.frame.height
                let lastAttrs = collectionViewLayout.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter, at: lastIndexPath
                )
                footerHeight = (lastAttrs?.frame.maxY ?? 0) - bottomHeaderHeight + attrs.sectionInset.bottom + attrs.minimumItemLineSpacing
            } else {
                let topHeaderHeight = attrs.frame.height
                let firstAttrs = collectionViewLayout.layoutAttributesForItem(at: firstIndexPath)
                headerHeight = (firstAttrs?.frame.minY ?? 0) - topHeaderHeight - attrs.sectionInset.top
                
                let bottomHeaderHeight = attrs.frame.height
                let lastAttrs = collectionViewLayout.layoutAttributesForItem(at: lastIndexPath)
                footerHeight = (lastAttrs?.frame.maxY ?? 0) + attrs.sectionInset.bottom - bottomHeaderHeight
            }
            
            let pinnedOffsetY = collectionView.safeAreaInsets.top + collectionView.contentOffset.y
            origin.y = min(max(pinnedOffsetY, headerHeight), footerHeight)
            return origin
        }
    }
}
