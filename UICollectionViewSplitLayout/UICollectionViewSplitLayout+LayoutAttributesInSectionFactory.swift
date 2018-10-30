//
//  UICollectionViewSplitLayout+LayoutAttributesInSectionFactory.swift
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
    class LayoutAttributesInSectionFactory {
        /// stack to calculate frames on one column
        class ItemColumnStack {
            let isNormalizing: Bool
            
            init(isNormalizing: Bool) {
                self.isNormalizing = isNormalizing
            }
            
            /// If isNormalizing is set true, refinedAttrs returns normalized height.
            var refinedAttrs: [UICollectionViewSplitLayoutAttributes] {
                if isNormalizing {
                    return normalizedAttrs
                } else {
                    return attributesList
                }
            }
            
            /// layout attributes on one column
            private var attributesList = [UICollectionViewSplitLayoutAttributes]()
            
            /// max height on one column
            var maxHeight: CGFloat {
                return attributesList.map{ $0.frame.height }.reduce(CGFloat(0)) { max($0, $1) }
            }
            
            /// outline size
            private var normalizedAttrs: [UICollectionViewSplitLayoutAttributes] {
                attributesList.forEach { $0.frame.size = CGSize(width: $0.frame.width, height: maxHeight) }
                return attributesList
            }

            /// reset all layout attributes
            func reset() {
                attributesList = []
            }
            
            /// add layout attributes
            func append(attrs: UICollectionViewSplitLayoutAttributes) {
                attributesList.append(attrs)
            }
        }
        
        func makeItems(for section: Int,
                       side: UICollectionViewSplitLayoutSide,
                       numberOfItems: Int,
                       firstPosition: CGPoint,
                       contentMostLeft: CGFloat,
                       contentWidth: CGFloat,
                       sectionInset: UIEdgeInsets,
                       minimumInterItemSpacing: CGFloat,
                       minimumItemLineSpacing: CGFloat,
                       isNormalizing: Bool,
                       sizingHandler: (IndexPath) -> CGSize) -> (attributes: [UICollectionViewSplitLayoutAttributes], lastPosition: CGPoint) {

            let columnStack = ItemColumnStack(isNormalizing: isNormalizing)
            var itemAttributes = [UICollectionViewSplitLayoutAttributes]()
            var currentPosition = firstPosition
            currentPosition.y += sectionInset.top
            currentPosition.x += sectionInset.left
            
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let size = sizingHandler(indexPath)
                
                if size.width == 0.0 || size.height == 0.0 {
                    continue
                }
                
                let needsLineBreak = isOverMostRightPosition(
                    of: side,
                    toPosition: currentPosition.x + size.width,
                    sectionInset: sectionInset,
                    contentMostLeft: contentMostLeft,
                    contentWidth: contentWidth
                )
                
                if needsLineBreak {
                    itemAttributes += columnStack.refinedAttrs
                    currentPosition =  CGPoint(
                        x: contentMostLeft + sectionInset.left,
                        y: columnStack.maxHeight + currentPosition.y + minimumItemLineSpacing
                    )
                    columnStack.reset()
                }
                
                let attr = UICollectionViewSplitLayoutAttributes(forCellWith: indexPath)
                attr.side = side
                attr.sectionInset = sectionInset
                attr.minimumItemLineSpacing = minimumItemLineSpacing
                attr.frame.origin = currentPosition
                attr.frame.size   = size
                columnStack.append(attrs: attr)
                
                currentPosition = CGPoint(
                    x: attr.frame.maxX + minimumInterItemSpacing,
                    y: attr.frame.minY
                )
            }
            
            itemAttributes += columnStack.refinedAttrs
            currentPosition = CGPoint(
                x: contentMostLeft,
                y: columnStack.maxHeight + currentPosition.y + sectionInset.bottom)
            columnStack.reset()
            
            return (itemAttributes, currentPosition)
        }
        
        /// position x is over right edge on the column
        /// - parameter side: UICollectionViewSplitLayoutSide
        /// - parameter x:    position
        /// - returns: position x is over the right edge
        func isOverMostRightPosition(
            of side: UICollectionViewSplitLayoutSide,
            toPosition x: CGFloat,
            sectionInset: UIEdgeInsets,
            contentMostLeft: CGFloat,
            contentWidth: CGFloat) -> Bool {
            
            let contentMostRight = (contentMostLeft + contentWidth)
            let sectionMostRight = contentMostRight - sectionInset.right
            return sectionMostRight < x
        }
        
        /// return layout attributes for each section header
        /// - parameter section:       Int
        /// - parameter nextPosition:  CGPoint
        /// - parameter side:          UICollectionViewSplitLayoutSide
        /// - returns: layout attributes for each section header
        func makeHeader(
            at section: Int,
            nextPosition: CGPoint,
            side: UICollectionViewSplitLayoutSide,
            sectionInset: UIEdgeInsets,
            minimumItemLineSpacing: CGFloat,
            headerSize: CGSize) -> UICollectionViewSplitLayoutAttributes? {
            if headerSize.width == 0.0 || headerSize.height == 0.0 {
                return nil
            }
            
            let headerAttributes = UICollectionViewSplitLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: section)
            )
            headerAttributes.side = side
            headerAttributes.sectionInset = sectionInset
            headerAttributes.minimumItemLineSpacing = minimumItemLineSpacing
            headerAttributes.frame.origin = nextPosition
            headerAttributes.frame.size = headerSize
            return headerAttributes
        }
        
        /// return layout attributes for each section footer
        /// - parameter section:       Int
        /// - parameter nextPosition:  CGPoint
        /// - parameter side:          UICollectionViewSplitLayoutSide
        /// - returns: layout attributes for each section footer
        func makeFooter(
            at section: Int,
            nextPosition: CGPoint,
            side: UICollectionViewSplitLayoutSide,
            sectionInset: UIEdgeInsets,
            minimumItemLineSpacing: CGFloat,
            footerSize: CGSize) -> UICollectionViewSplitLayoutAttributes? {
            if footerSize.width == 0.0 || footerSize.height == 0.0 {
                return nil
            }
            
            let footerAttributes = UICollectionViewSplitLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: IndexPath(item: 0, section: section)
            )
            footerAttributes.side = side
            footerAttributes.sectionInset = sectionInset
            footerAttributes.minimumItemLineSpacing = minimumItemLineSpacing
            footerAttributes.frame.origin = nextPosition
            footerAttributes.frame.size = footerSize
            return footerAttributes
        }
        
        func makeBackgroundDecoration(
            section: Int,
            itemsLeftTopPosition: CGPoint,
            sectionBottomPositionY: CGFloat,
            side: UICollectionViewSplitLayoutSide,
            contentWidth: CGFloat,
            backgroundColor: UIColor?) -> UICollectionViewSplitLayoutAttributes {
            
            let decorationAttrs = UICollectionViewSplitLayoutAttributes(
                forDecorationViewOfKind: UICollectionViewSplitLayoutBackgroundView.className,
                with: IndexPath(item: 0, section: section)
            )
            
            decorationAttrs.frame.origin = itemsLeftTopPosition
            decorationAttrs.frame.size =  CGSize(
                width: contentWidth,
                height: sectionBottomPositionY - decorationAttrs.frame.minY
            )
            
            decorationAttrs.side = side
            decorationAttrs.zIndex = -1
            decorationAttrs.decoratedSectionBackgroundColor = backgroundColor
            return decorationAttrs
        }
    }
}
