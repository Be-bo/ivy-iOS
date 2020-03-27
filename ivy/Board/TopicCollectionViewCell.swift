//
//  TopicCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-03.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class TopicCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var viewingImage: UIImageView!
    @IBOutlet weak var numberViewingLabel: StandardLabel!
    @IBOutlet weak var authOrCommentLabel: StandardLabel!
    @IBOutlet weak var viewHoldingBottonBit: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

}
