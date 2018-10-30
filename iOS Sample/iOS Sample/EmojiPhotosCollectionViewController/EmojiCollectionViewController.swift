//
//  SplitCollectionViewController.swift
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

struct Emoji {
    struct CodePoint {
        let label: String
        let value: String
    }
    
    let mainCharacter: String
    let name: String
    let codePoint: [CodePoint]
    let others: [String]
}

enum EmojiDataSource {
    case summary(mianCharacter: String, name: String)
    case classification(classification: Emoji.CodePoint)
    case sampleImage(imageName: String)
}

struct EmojiDataSourceFactory {
    static func make(emoji: Emoji) -> [(sectionTitle: String?, items: [EmojiDataSource], side: UICollectionViewSplitLayoutSide, hasFooter: Bool)] {
        return [
            (sectionTitle: nil, items: [.summary(mianCharacter: emoji.mainCharacter, name: emoji.name)], side: .left, hasFooter: false),
            (sectionTitle: nil, items: emoji.codePoint.map { .classification(classification: $0) }, side: .left, hasFooter: true),
            (sectionTitle: "Emoji Collection", items: emoji.others.map { .sampleImage(imageName: $0) }, side: .right, hasFooter: false)
        ]
    }
}

class EmojiCollectionViewController: UICollectionViewController {
    static let summaryCollectionViewCellSizing = UINib(nibName: "SummaryCollectionViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! SummaryCollectionViewCell
    static let codePointCollectionViewCellSizing = UINib(nibName: "CodePointCollectionViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! CodePointCollectionViewCell
    
    private let emoji = Emoji(
        mainCharacter: "👨‍👩‍👧‍👦",
        name: "Family: Man, Woman, Girl, Boy",
        codePoint: [
            .init(label: "👨", value: "U+1F468"),
            .init(label: "", value: "U+200D"),
            .init(label: "👩", value: "U+1F469"),
            .init(label: "", value: "U+200D"),
            .init(label: "👧", value: "U+1F467"),
            .init(label: "", value: "U+200D"),
            .init(label: "👦", value: "U+1F466")
        ],
        others: ["👨🏻‍⚕️", "👩‍🎓", "👨‍🏫", "👩‍🌾", "👨‍🍳", "👩‍🔧", "👨‍🏭", "👩‍💼", "👨‍🔬", "👩‍💻", "👨‍🎤", "👩‍🎨", "👨‍✈️", "👩‍🚀", "👨‍🚒", "👮‍♀️", "🕵️‍♂️", "👷‍♀️"]
    )
    let layout = UICollectionViewSplitLayout()
    private var dataSource = [(sectionTitle: String?, items: [EmojiDataSource], side: UICollectionViewSplitLayoutSide, hasFooter: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.splitSpacing = 16
        if #available(iOS 11.0, *) {
            layout.sectionPinToVisibleBounds = true
        }
        collectionView.collectionViewLayout = layout

        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.register(UINib(nibName: "SimpleCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SimpleCollectionReusableView")
        collectionView.register(UINib(nibName: "SimpleCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SimpleCollectionReusableView")
        collectionView.register(UINib(nibName: "CodePointCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CodePointCollectionViewCell")
        collectionView.register(UINib(nibName: "OtherEmojiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OtherEmojiCollectionViewCell")
        collectionView.register(UINib(nibName: "SummaryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SummaryCollectionViewCell")
        
        
        dataSource = EmojiDataSourceFactory.make(emoji: emoji)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataSource[indexPath.section].items[indexPath.item] {
        case .summary(let character, let name):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath) as! SummaryCollectionViewCell
            cell.nameLabel.text = name
            cell.emojiLabel.text = character
            return cell
        case .classification(let classification):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CodePointCollectionViewCell", for: indexPath) as! CodePointCollectionViewCell
            cell.categoryLabel.text = classification.label
            cell.nameLabel.text = classification.value
            return cell
        case .sampleImage(let character):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherEmojiCollectionViewCell", for: indexPath) as! OtherEmojiCollectionViewCell
            cell.emojiLabel.text = character
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SimpleCollectionReusableView", for: indexPath) as! SimpleCollectionReusableView
        view.titleLabel.text = dataSource[indexPath.section].sectionTitle
        return view
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layout.leftSideRatio = size.width > size.height ? 0.4 : UICollectionViewSplitLayoutSide.left.leftSideRatio
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            self?.layout.invalidateLayout()
        }) { (context) in }
    }
}

extension EmojiCollectionViewController: UICollectionViewDelegateSectionSplitLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        switch dataSource[indexPath.section].items[indexPath.item] {
        case .summary(_, let name):
            EmojiCollectionViewController.summaryCollectionViewCellSizing.nameLabel.text = name
            var size = UIView.layoutFittingCompressedSize
            size.width = layout.contentWidth(of: side)
            return EmojiCollectionViewController.summaryCollectionViewCellSizing.contentView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        case .classification(let classification):
            EmojiCollectionViewController.codePointCollectionViewCellSizing.categoryLabel.text = classification.label
            EmojiCollectionViewController.codePointCollectionViewCellSizing.nameLabel.text = classification.value
            var size = UIView.layoutFittingCompressedSize
            size.width = layout.contentWidth(of: side)
            return EmojiCollectionViewController.codePointCollectionViewCellSizing.contentView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        case .sampleImage(_):
            let num = layout.leftSideRatio == UICollectionViewSplitLayoutSide.left.leftSideRatio ? 2 : 3
            let width = layout.calculateFixedWidthRaughly(to: num, of: side, minimumInterItemSpacing: layout.minimumInterItemSpacing, sectionInset: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        if let side = UICollectionViewSplitLayoutSide(leftSideRatio: layout.leftSideRatio) {
            return side
        } else {
            return dataSource[section].side
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        return dataSource[section].sectionTitle != nil ? CGSize(width: layout.contentWidth(of: side), height: 60) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, itemsBackgroundColorFor section: Int, side: UICollectionViewSplitLayoutSide) -> UIColor? {
        return .white
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> UIEdgeInsets {
        switch dataSource[section].items.first {
        case .sampleImage?:
            return UIEdgeInsets(top: 0, left: 8, bottom: 16, right: 8)
        case .classification?:
            return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        default:
            return .zero
        }
    }
}
