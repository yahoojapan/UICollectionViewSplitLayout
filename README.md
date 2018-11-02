![uicollectionviewsplitlayout_logo](https://user-images.githubusercontent.com/18320004/47694680-0420a280-dc42-11e8-98b4-55de463a735a.png)

[![Platform](https://img.shields.io/cocoapods/p/UICollectionViewSplitLayout.svg?style=flat)](http://cocoapods.org/pods/UICollectionViewSplitLayout)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![License](https://img.shields.io/cocoapods/l/UICollectionViewSplitLayout.svg?style=flat)](http://cocoapods.org/pods/UICollectionViewSplitLayout)
[![Version](https://img.shields.io/cocoapods/v/UICollectionViewSplitLayout.svg?style=flat)](http://cocoapods.org/pods/UICollectionViewSplitLayout)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UICollectionViewSplitLayout makes collection view more responsive.

![oct-30-2018 19-53-04](https://user-images.githubusercontent.com/18320004/47713409-8da19600-dc7d-11e8-896d-d868de48589f.gif)

# What's this?
UICollectionViewSplitLayout is a subclass of UICollectionViewLayout. It can divide sections into two columns.

Collection view has "Section" which organizes item collection.
UICollectionViewFlowLayout places them from top to bottom.

On the other hands, UICollectionViewSplitLayout divides sections into two columns.
You can dynamically update the width of them and which column each section is on.

For example, UICollectionViewSplitLayout can change the number of column according to device orientation. All you need is assigning value to ```leftSideRatio``` when changing screen size. This figure describes that a collection view has three sections (red, blue and green) and UICollectionViewSplitLayout aligns them side by side.

![rendering_well](https://user-images.githubusercontent.com/18320004/47711313-4bc22100-dc78-11e8-9a05-16c1ac149f99.png)

UICollectionViewSplitLayout looks like UIStackView. 
But it has a more memory efficient architecture. 
So you can align a lot of cells with it.

It may be hard to imagine how it works, please run [EmojiCollectionViewController](https://github.com/yahoojapan/UICollectionViewSplitLayout/blob/master/iOS%20Sample/iOS%20Sample/EmojiPhotosCollectionViewController/EmojiCollectionViewController.swift).

# Requirement
+ iOS 9.0+
+ Swift 4.2

# Installation

### Carthage
#### 1. create Cartfile

```ruby:Cartfile
github "https://github.com/yahoojapan/UICollectionViewSplitLayout"

```

#### 2. install
```
> carthage update
```

### CocoaPods
#### 1. create Podfile
```ruby:Podfile
platform :ios, '8.0'
use_frameworks!

pod "UICollectionViewSplitLayout", :git => 'https://github.com/yahoojapan/UICollectionViewSplitLayout.git'
```

#### 2. install
```
> pod install
```

# Getting Started

It’s good to start from replacing UICollectionViewFlowLayout with UICollectionViewSplitLayout.

## 1. Create UICollectionViewController

Set UICollectionViewController on Storyboard.

<img width="300" alt="2018-10-24 10 28 36" src="https://user-images.githubusercontent.com/18320004/47400738-7e9c7e80-d779-11e8-9753-52e62ced2afc.png">

Add implementation to construct a collection view.

```swift
import UIKit

private let reuseIdentifier = "Cell"

class BasicCollectionViewController: UICollectionViewController {
    
    var dataSource: [[UIColor]] = [
        (0..<20).map { _ in .red },
        (0..<20).map {  _ in .blue },
        (0..<20).map {  _ in .green }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    // MARK: UICollectionViewDataSource

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
```

Build the code.

<img width="300" alt="2018-10-24 10 27 42" src="https://user-images.githubusercontent.com/18320004/47400781-b4d9fe00-d779-11e8-86e7-2d35ab45822c.png">

It shows three sections whose items have different colors.

## 2. Input "UICollectionViewSplitLayout" as Custom Layout Class

Switch "Flow" to "Custom" in Layout attribute and input "UICollectionViewSplitLayout" into Class and Module attributes.

<img width="316" alt="2018-10-30 11 07 59" src="https://user-images.githubusercontent.com/18320004/47691120-1e538400-dc34-11e8-821b-3b9bafb2dbfc.png">


## 3. Assign parameters to UICollectionViewSplitLayout object

Connect the layout class to source code. Assign the parameters on viewDidLoad()

```swift
    @IBOutlet weak var layout: UICollectionViewSplitLayout!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //...
        //...
        
        // margins for each section
        layout.minimumItemLineSpacing = 8
        layout.minimumInterItemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Column Setting
        layout.leftSideRatio = 0.4
        layout.splitSpacing = 8
       
        //...
        //...
    }
```

## 4. Implement the layout delegate for UICollectionViewSplitLayout

Implement UICollectionViewDelegateTwoColumnLayout. The following methods is required.

```swift
extension BasicCollectionViewController: UICollectionViewDelegateSectionSplitLayout {
    // Fix the size of each item as UICollectionViewDelegateFlowLayout does. calculateFixedWidthRaughly() is utility method UICollectionViewSplitLayout has.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize {
        let width = layout.calculateFixedWidthRaughly(
                               to: 3, 
                               of: side, 
                               minimumInterItemSpacing: layout.minimumInterItemSpacing, 
                               sectionInset: layout.sectionInset)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide {
        // when a section number is odd, the items are placed into left side. 
        return section % 2 == 0 ? .left : .right
    }
}
```

It arranges the sections side by side.

<img width="300" alt="2018-10-30 23 41 03" src="https://user-images.githubusercontent.com/18320004/47726194-52af5a80-dc9d-11e8-82da-72e799837f6c.png">


See [BasicCollectionViewController](https://github.com/yahoojapan/UICollectionViewSplitLayout/blob/master/iOS%20Sample/iOS%20Sample/BasicCollectionViewController/BasicCollectionViewController.swift) to run the above example.

# Architecture

It is one of the UICollectionViewLayout. So you can change a layout without updating code in UICollectionViewDelegate and UICollectionViewDataSource. It is reasonable to apply a new layout. All you have to do is studying layout class and the delegate.

# Usage

## How to Split

UICollectionViewSplitLayout calculates width of the left and right side with the following parameter.

```swift
leftSideRatio = 0.4
```

It has a Float value which is the ration of left side to the entire width. 
In addition, left and right sides have spacing between them.

```swift
splitSpacing = 10
```

If a collection view has 110pt width, the above setting requires 40pt width to the left side and 60pt width to the right side.
When leftSideRatio has 0.0, splitSpacing is ignored as an exception.

You can choose which side each section is in. UICollectionViewDeleagteSectionSplitLayout provides a method to do that.

```swift
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sideForSection section: Int) -> UICollectionViewSplitLayoutSide
```

UICollectionViewSplitLayout hooks the delegate every time a collection view calls invalidateLayout().

## Margins

UICollectionViewSplitLayout has these parameters to determine margins.

```swift
/// The minimum spacing to use between items in the same row.
open var minimumInterItemSpacing: CGFloat
/// The minimum spacing to use between lines of items in the grid.
open var minimumItemLineSpacing: CGFloat
/// The margins used to lay out content in a section
open var sectionInset: UIEdgeInsets
```

They have the corresponding delegate methods by section (optional).

```swift
// section inset to each section
@objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> UIEdgeInsets
    
// minimumInterItemSpacing to each section
@objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInterItemSpacingForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> CGFloat

// minimumItemLineSpacing to each section
@objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumItemLineSpacingForSectionAtIndex section: Int, side: UICollectionViewSplitLayoutSide) -> CGFloat
```

## Pinning (iOS 11~)

UICollectionViewSplitLayout pins seciton header like UICollectionViewFlowLayout. This feature is supported from iOS 11. ```sectionPinToVisibleBounds``` enables to work it.

## Setting Attriutes

UICollectionViewSplitLayout uses three kinds of attribute, item, supplementary view and decoration view.

### Item 
You need to implement cell sizing. UICollectionViewSplitLayout provides a delegate to implement it.

```swift
func collectionView(
    _ collectionView: UICollectionView, 
    layout collectionViewLayout: UICollectionViewLayout, 
    sizeForItemAtIndexPath indexPath: IndexPath, 
    width: CGFloat, 
    side: UICollectionViewSplitLayoutSide) -> CGSize
```

You can divide the sizes evenly with a utility method.

```swift
open func calculateFixedWidthRaughly(
    to num: Int, 
    of side: UICollectionViewSplitLayoutSide, 
    minimumInterItemSpacing: CGFloat, 
    sectionInset: UIEdgeInsets) -> CGFloat
```

### Supplementary view for header and footer
You can implement header and footer sizing. UICollectionViewSplitLayout provides delegate to implement it. 
If the sizes are zero, header and footer are ignoured.

```swift size
// header
@objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize

// footer size
@objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int, width: CGFloat, side: UICollectionViewSplitLayoutSide) -> CGSize
```

### decoration view for backgroundColor

UICollectionSplitLayout has a special decoration view. It has the same size as the section. You can determine backgroundColor to each section with the following delegate.

```swift
@objc optional func collectionView(
    _ collectionView: UICollectionView, 
    layout collectionViewLayout: UICollectionViewLayout,
    itemsBackgroundColorFor section: Int, 
    side: UICollectionViewSplitLayoutSide) -> UIColor?
```

## Line Height Normalization
If isNormalizingLineHeight is true, item height is adjusted to outline height of the line (defalut: false).

```swift
open var isNormalizingLineHeight: Bool
```

# License

The MIT License (MIT)

Copyright (c) 2018 Yahoo Japan Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
