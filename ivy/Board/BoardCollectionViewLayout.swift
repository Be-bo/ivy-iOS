//
//  BoardCollectionViewLayout.swift
//  ivy-iOS
//
//  Created by Robert on 2020-03-28.
//  Copyright © 2020 ivy social network. All rights reserved.
//
//  Inspiration: https://www.ductran.co/products/free-pinterest-newsfeed-w-uicollectionview/categories/262590/posts/799528

import UIKit

protocol BoardLayoutDelegate: class {
    func collectionView(collectionView: UICollectionView, heightForLabelAt indexPath: IndexPath, with width: CGFloat)->CGFloat
}

class BoardCollectionViewLayout: UICollectionViewLayout {
    var delegate: BoardLayoutDelegate?
    
    var numberOfColumns: CGFloat = 2
    var cellPadding: CGFloat = 5
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    private var cachedAttributes = [UICollectionViewLayoutAttributes]() //caching of specific layout vals for items to improve performance
    
    override func prepare() { //called when layout changed
//        if cachedAttributes.isEmpty{ //creating attributes from scratch
            let columnWidth = contentWidth/numberOfColumns
            
            var xOffsets = [CGFloat]() //size 2 for 2 columns
            for column in 0..<Int(numberOfColumns){
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var yOffsets = [CGFloat](repeating: 0, count: Int(numberOfColumns)) //both columns start at 0 on the y axis
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0){ //for each item in section 0 create the attributes
                let indexPath = IndexPath(item: item, section: 0)
                
                if(indexPath.item == 0){ //if create topic button
                    let width: CGFloat = 80
                    let labelHeight: CGFloat = 30
                    let height: CGFloat = cellPadding + labelHeight + cellPadding
                    let frame = CGRect(x: 0, y: 0, width: columnWidth*2, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cachedAttributes.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    for i in 0..<yOffsets.count{ //for all/both columns set the start offset (because the create topic button spans all columns) to be at the end of create topic btn
                        yOffsets[i] = yOffsets[i] + height
                    }
                }else if(indexPath.item == 1){ //if QOTD
                    let width: CGFloat = columnWidth * 2 - cellPadding * 2
                    let labelHeight: CGFloat = (delegate?.collectionView(collectionView: collectionView!, heightForLabelAt: indexPath, with: width))!
                    let height: CGFloat = cellPadding + labelHeight + cellPadding
                    let frame = CGRect(x: 0, y: yOffsets[column], width: columnWidth*2, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cachedAttributes.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    for i in 0..<yOffsets.count{ //for all/both columns set the start offset (because the QOTD spans all columns) to be at the end of the QOTD
                        yOffsets[i] = yOffsets[i] + height
                    }
                    
                }else{ //if standard topic cell
                    let width: CGFloat = columnWidth - cellPadding * 2
                    let labelHeight: CGFloat = (delegate?.collectionView(collectionView: collectionView!, heightForLabelAt: indexPath, with: width))!
                    let height: CGFloat = cellPadding + labelHeight + cellPadding
                    let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cachedAttributes.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffsets[column] = yOffsets[column] + height //set the start of the next topic for that given column to be at the end of the current topic in the current column
                    if column >= (Int(numberOfColumns) - 1){ //if in bounds increment, if not set column to 0
                        column = 0
                    }else{
                        column += 1
                    }
                }
            }
//        }
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cachedAttributes{
            if attributes.frame.intersects(rect){
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
