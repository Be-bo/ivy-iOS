//
//  TopicCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-03.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class TopicCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var viewingImage: UIImageView!
    @IBOutlet weak var numberViewingLabel: StandardLabel!
    @IBOutlet weak var authOrCommentLabel: StandardLabel!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHoldingBottonBit: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
