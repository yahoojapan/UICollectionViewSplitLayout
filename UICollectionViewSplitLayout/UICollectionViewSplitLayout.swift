//
//  UICollectionViewSplitLayout.swift
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

/// This class defines which side each section is on
@objc public enum UICollectionViewSplitLayoutSide: Int {
    case left = 1, right = 0
    
    public init?(leftSideRatio: CGFloat) {
        if leftSideRatio == 1 {
            self = .left
        } else if leftSideRatio == 0 {
            self = .right
        } else {
            return nil
        }
    }
    
    public var leftSideRatio: CGFloat {
        return CGFloat(rawValue)
    }

    public func needsIgnored(to leftSideRatio: CGFloat) -> Bool {
        return ignoredLeftSideRatio == leftSideRatio
    }
    
    private var ignoredLeftSideRatio: CGFloat {
        switch self {
        case .left:
            return UICollectionViewSplitLayoutSide.right.leftSideRatio
        case .right:
            return UICollectionViewSplitLayoutSide.left.leftSideRatio
        }
    }
    
}

/// Custom invalidation context for UICollectionViewSplitLayout.
open class UICollectionViewSplitLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
    public var isInvalidationBoundsChage = false
}

/// Custom layout attributes for UICollectionViewSplitLayout.
open class UICollectionViewSplitLayoutAttributes: UICollectionViewLayoutAttributes {
    public var side: UICollectionViewSplitLayoutSide!
    public var sectionInset: UIEdgeInsets = .zero
    public var minimumItemLineSpacing: CGFloat = 0
    public var decoratedSectionBackgroundColor: UIColor?
}

/// delegate class for UICollectionViewSplitLayout.
@objc public protocol UICollectionViewDelegateSectionSplitLayout: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> UIEdgeInsets
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInterItemSpacingForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumItemLineSpacingForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, itemsBackgroundColorFor section: Int, side: UICollectionViewSplitLayoutSide) -> UIColor?
}

/// layout class to divide sections into left and right
open class UICollectionViewSplitLayout: UICollectionViewLayout {
    public enum SectionInsetReference: Int {
        case fromContentInset
        case fromSafeArea
    }

    /// The minimum spacing to use between items in the same row.
    open var minimumInterItemSpacing: CGFloat = 0
    
    /// The minimum spacing to use between lines of items in the grid.
    open var minimumItemLineSpacing: CGFloat = 0
    
    /// The margins used to lay out content in a section
    open var sectionInset: UIEdgeInsets = .zero
    
    /// contentInset of collection view
    private var contentInset: UIEdgeInsets {
        get {
            return collectionView?.contentInset ?? .zero
        }
        set {
            collectionView?.contentInset = newValue
        }
    }
    
    private var pinnedPositionCalculator = PinnedPositionCalculator()
    private var layoutAttributesInSectionFactory = LayoutAttributesInSectionFactory()
    
    func configure(
        pinnedPositionCalculator: PinnedPositionCalculator,
        layoutAttributesInSectionFactory: LayoutAttributesInSectionFactory) {
        
        self.pinnedPositionCalculator = pinnedPositionCalculator
        self.layoutAttributesInSectionFactory = layoutAttributesInSectionFactory
    }
    
    private var _sectionInsetReference: SectionInsetReference = .fromSafeArea
    @available(iOS 11.0, *)
    public var sectionInsetReference: SectionInsetReference {
        get {
            return _sectionInsetReference
        }
        set {
            _sectionInsetReference = newValue
        }
    }
    
    /// A Boolean value indicating whether pin to the top of the collection view bounds during scrolling.
    private var _sectionPinToVisibleBounds: Bool = false
    @available(iOS 11.0, *)
    public var sectionPinToVisibleBounds: Bool {
        get {
            return _sectionPinToVisibleBounds
        }
        set {
            _sectionPinToVisibleBounds = newValue
        }
    }
    
    /// left:right -> leftSideRatio : (1 - leftSideRatio)
    open var leftSideRatio: CGFloat = 1
    
    /// The margin between left and right sides
    /// If leftSideRaio is 1 or 0, the value of this property is ignored.
    open var splitSpacing: CGFloat = 0
    
    /// If true, item height is adjusted to outline height of the line (defalut: false).
    open var isNormalizingLineHeight: Bool = false
    
    private var actualSideSpacing: CGFloat {
        return (leftSideRatio == 1 || leftSideRatio == 0) ? 0 : splitSpacing
    }
    
    // MARK:- layout cache
    
    private var sectionAttributes = [[UICollectionViewSplitLayoutAttributes]]()
    private var sectionSupplymentalyAttributes = [[UICollectionViewSplitLayoutAttributes]]()
    private var sectionDecorationAttributes = [UICollectionViewSplitLayoutAttributes]()
    private var tailPositionY = CGFloat(0)
    
    // MARK:- calculation for frame
    
    /// divides content width equally to calculate item width.
    ///
    /// - Parameters:
    ///   - num: number of item on line
    ///   - side: which side
    ///   - minimumInterItemSpacing: The minimum spacing to use between items in the same row
    ///   - sectionInset: The minimum spacing to use between lines of items in the grid
    /// - Returns: item width
    open func calculateFixedWidthRaughly(
        to num: Int,
        of side: UICollectionViewSplitLayoutSide,
        minimumInterItemSpacing: CGFloat,
        sectionInset: UIEdgeInsets) -> CGFloat {

        guard 0 < num else { return 0 }
        let horizontalSpacing = sectionInset.horizontal + (minimumInterItemSpacing * (CGFloat(num) - 1))
        let validWidth = contentWidth(of: side) - horizontalSpacing
        return CGFloat(Int(validWidth) / num)
    }
    
    /// return left edge of the side
    /// - parameter side: UICollectionViewSplitLayoutSide
    /// - returns: left edge of the side
    open func contentMostLeft(of side: UICollectionViewSplitLayoutSide) -> CGFloat {
        switch side {
        case .left:
            return contentInsetStartingInsets.left
        case .right:
            return contentInsetStartingInsets.left + contentWidth(of: .left) + actualSideSpacing
        }
    }
    
    
    open func contentWidth(of side: UICollectionViewSplitLayoutSide) -> CGFloat {
        let totalContentWidth = (collectionViewContentSize.width - actualSideSpacing)
        switch side {
        case .left:
            return totalContentWidth * leftSideRatio
        case .right:
            return totalContentWidth - (totalContentWidth * leftSideRatio)
        }
    }
    
    public override init() {
        super.init()
        register(
            UICollectionViewSplitLayoutBackgroundView.self,
            forDecorationViewOfKind: UICollectionViewSplitLayoutBackgroundView.className
        )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register(
            UICollectionViewSplitLayoutBackgroundView.self,
            forDecorationViewOfKind: UICollectionViewSplitLayoutBackgroundView.className
        )
    }
    
    //MARK:- UICollectionViewLayout
    
    override open class var invalidationContextClass: AnyClass {
        return UICollectionViewSplitLayoutInvalidationContext.self
    }
    
    override open class var layoutAttributesClass: AnyClass {
        return UICollectionViewLayoutAttributes.self
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let leftSideAttributes = sectionAttributes.joined().filter({ $0.side == .left })
        let rightSideAttributes = sectionAttributes.joined().filter({ $0.side == .right })
        
        let leftSectionInRectAttributes = leftSideAttributes.filter { rect.intersects($0.frame) }
        let rightSectionInRectAttributes = rightSideAttributes.filter { rect.intersects($0.frame) }
        let layoutAttributes = leftSectionInRectAttributes + rightSectionInRectAttributes
        let supplymentalyAttributesInRect = sectionSupplymentalyAttributes.joined().filter { (supplementary) in
            layoutAttributes.filter({ $0.indexPath.section == supplementary.indexPath.section }).count > 0
        }
        
        let sectionList = Set(layoutAttributes.map { $0.indexPath.section })
        let backgroundViewDecorationAttributesInRect =  sectionList.compactMap {
            layoutAttributesForDecorationView(
                ofKind: UICollectionViewSplitLayoutBackgroundView.className,
                at: IndexPath(item: 0, section: $0)
            )
        }

        if #available(iOS 11.0, *), sectionPinToVisibleBounds {
            for attrs in supplymentalyAttributesInRect where attrs.representedElementKind == UICollectionView.elementKindSectionHeader {
                if let origin = pinnedPositionCalculator.execute(of: attrs, collectionViewLayout: self) {
                    attrs.zIndex = 1024
                    attrs.frame.origin = origin
                }
            }
        }

        return supplymentalyAttributesInRect + layoutAttributes + backgroundViewDecorationAttributesInRect
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionAttributes[indexPath.section][indexPath.item]
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionDecorationAttributes.first(where: { $0.representedElementKind == elementKind && $0.indexPath.section == indexPath.section })
    }
    
    override open var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        let size = CGSize(
            width: collectionView.bounds.width - contentInset.horizontal - contentInsetStartingInsets.horizontal,
            height: tailPositionY + contentInset.bottom
        )
        return size
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        if let _context = context as? UICollectionViewSplitLayoutInvalidationContext {
            _context.isInvalidationBoundsChage = true
        }
        return context
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if let _context = context as? UICollectionViewSplitLayoutInvalidationContext,
            !_context.isInvalidationBoundsChage {
            recalculateLayoutAttributes()
        }
    }

    //MARK:- private


    /// makes layout attributes
    /// - parameter side:   UICollectionViewSplitLayoutSide
    /// - parameter section: Int
    /// - parameter currentPosition: CGPoint
    /// - returns: ([UICollectionViewSplitLayoutAttributes], [UICollectionViewSplitLayoutAttributes], CGPoint)
    private func makeLayoutAttributesInSection(
        of side: UICollectionViewSplitLayoutSide,
        section: Int,
        currentPosition: CGPoint,
        minimumItemLineSpacing: CGFloat,
        minimumInterItemSpacing: CGFloat,
        contentMostLeft: CGFloat,
        contentWidth: CGFloat,
        collectionView: UICollectionView?) -> (attrsList: [UICollectionViewSplitLayoutAttributes], supplementalyAttrsList: [UICollectionViewSplitLayoutAttributes], decorationAttrsList: UICollectionViewSplitLayoutAttributes, currentPosition: CGPoint)? {
        guard let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateSectionSplitLayout else { return nil }
        
        var currentPosition = currentPosition
        var supplementalyAttributes = [UICollectionViewSplitLayoutAttributes]()
        
        let sectionInset = delegate.collectionView?(
            collectionView,
            layout: self,
            insetForSectionAtIndex:
            section,
            side: side) ?? self.sectionInset

        let headerSize = delegate.collectionView?(
            collectionView,
            layout: self,
            referenceSizeForHeaderInSection: section,
            width: contentWidth,
            side: side) ?? .zero
        
        let headerAttributes = layoutAttributesInSectionFactory.makeHeader(
            at: section,
            nextPosition: currentPosition,
            side: side,
            sectionInset: sectionInset,
            minimumItemLineSpacing: minimumItemLineSpacing,
            headerSize: headerSize
        )
        
        if let headerAttributes = headerAttributes {
            supplementalyAttributes.append(headerAttributes)
            currentPosition = CGPoint(
                x: contentMostLeft,
                y: headerAttributes.frame.maxY
            )
        }
                                                    
        let itemsLeftTopPosition = currentPosition
        let (attrsList, lastPosition) = layoutAttributesInSectionFactory.makeItems(
            for: section,
            side: side,
            numberOfItems: collectionView.numberOfItems(inSection: section),
            firstPosition: currentPosition,
            contentMostLeft: contentMostLeft,
            contentWidth: contentWidth,
            sectionInset: sectionInset,
            minimumInterItemSpacing: minimumInterItemSpacing,
            minimumItemLineSpacing: minimumItemLineSpacing,
            isNormalizing: isNormalizingLineHeight,
            sizingHandler: { indexPath in
               return delegate.collectionView(
                    collectionView,
                    layout: self,
                    sizeForItemAtIndexPath: indexPath,
                    width: contentWidth,
                    side: side
                )
            })
        currentPosition = lastPosition

        let decorationBackgroundColor = delegate.collectionView?(
            collectionView,
            layout: self,
            itemsBackgroundColorFor: section,
            side: side
        )
        
        let decorationAttrs = layoutAttributesInSectionFactory.makeBackgroundDecoration(
            section: section,
            itemsLeftTopPosition: itemsLeftTopPosition,
            sectionBottomPositionY: currentPosition.y,
            side: side,
            contentWidth: contentWidth,
            backgroundColor: decorationBackgroundColor
        )
        
        let footerSize = delegate.collectionView?(
            collectionView,
            layout: self,
            referenceSizeForFooterInSection: section,
            width: contentWidth,
            side: side) ?? .zero
        
        let footerAttributes = layoutAttributesInSectionFactory.makeFooter(
            at: section,
            nextPosition: currentPosition,
            side: side,
            sectionInset: sectionInset,
            minimumItemLineSpacing: minimumItemLineSpacing,
            footerSize: footerSize
        )
        
        if let footerAttributes = footerAttributes {
            supplementalyAttributes.append(footerAttributes)
            currentPosition = CGPoint(
                x: contentMostLeft,
                y: footerAttributes.frame.maxY
            )
        }

        return (
            attrsList: attrsList,
            supplementalyAttrsList: supplementalyAttributes,
            decorationAttrsList: decorationAttrs,
            currentPosition: currentPosition
        )
    }
    

    /// starting point of content ineset
    var contentInsetStartingInsets: UIEdgeInsets {
        guard #available(iOS 11.0, *) else {
            return .zero
        }
        
        switch sectionInsetReference {
        case .fromContentInset:
            return .zero
        case .fromSafeArea:
            return collectionView?.safeAreaInsets ?? .zero
        }
    }

    /// initializes and calculates layout attributes for each elements
    private func recalculateLayoutAttributes() {
        guard let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateSectionSplitLayout else { return }
        
        sectionAttributes = []
        sectionSupplymentalyAttributes = []
        sectionDecorationAttributes = []
        tailPositionY = 0
        
        let contentMostLeftOnLeftSide = contentMostLeft(of: .left)
        let contentMostLeftOnRightSide = contentMostLeft(of: .right)

        var leftSideIncrementedPosition  = CGPoint(x: contentMostLeftOnLeftSide,  y: 0)
        var rightSideIncrementedPosition = CGPoint(x: contentMostLeftOnRightSide, y: 0)
        
        for section in 0..<collectionView.numberOfSections {
            let side = delegate.collectionView(collectionView, layout: self, sideForSection: section)
            
            if side.needsIgnored(to: leftSideRatio) {
                continue
            }
            
            let _minimumItemLineSpacing = delegate.collectionView?(
                collectionView,
                layout: self,
                minimumItemLineSpacingForSectionAtIndex: section, side: side) ?? minimumItemLineSpacing
            let _minimumInterItemSpacing = delegate.collectionView?(
                collectionView,
                layout: self,
                minimumInterItemSpacingForSectionAtIndex: section, side: side) ?? minimumInterItemSpacing
            
            switch side {
            case .left:
                let _attributes = makeLayoutAttributesInSection(
                    of: .left,
                    section: section,
                    currentPosition: leftSideIncrementedPosition,
                    minimumItemLineSpacing: _minimumItemLineSpacing,
                    minimumInterItemSpacing: _minimumInterItemSpacing,
                    contentMostLeft: contentMostLeftOnLeftSide,
                    contentWidth: contentWidth(of: .left),
                    collectionView: collectionView
                )
                
                if let (attrList, supplementaryList, decorationAttributes, currentPosition) = _attributes {
                    let maxY = max(supplementaryList.last?.frame.maxY ?? 0, currentPosition.y)
                    tailPositionY = max(tailPositionY, maxY)
                    
                    leftSideIncrementedPosition = currentPosition
                    sectionAttributes.append(attrList)
                    sectionSupplymentalyAttributes.append(supplementaryList)
                    sectionDecorationAttributes.append(decorationAttributes)
                }
            case .right:
                let _attributes = makeLayoutAttributesInSection(
                    of: .right,
                    section: section,
                    currentPosition: rightSideIncrementedPosition,
                    minimumItemLineSpacing: _minimumItemLineSpacing,
                    minimumInterItemSpacing: _minimumInterItemSpacing,
                    contentMostLeft: contentMostLeftOnRightSide,
                    contentWidth: contentWidth(of: .right),
                    collectionView: collectionView
                )
                
                if let (attrList, supplementaryList, decorationAttributes, currentPosition) = _attributes {
                    let maxY = max(supplementaryList.last?.frame.maxY ?? 0, currentPosition.y)
                    tailPositionY = max(tailPositionY, maxY)
                    
                    rightSideIncrementedPosition = currentPosition
                    sectionAttributes.append(attrList)
                    sectionSupplymentalyAttributes.append(supplementaryList)
                    sectionDecorationAttributes.append(decorationAttributes)
                }
            }
        }
    }
}

// MARK:- background view for each seciton

class UICollectionViewSplitLayoutBackgroundView: UICollectionReusableView {
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let _layoutAttribute = layoutAttributes as? UICollectionViewSplitLayoutAttributes {
            backgroundColor = _layoutAttribute.decoratedSectionBackgroundColor
        }
    }
}

// MARK:- Utility Extension

private extension UIEdgeInsets {
    var horizontal: CGFloat {
        return left + right
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
}

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
