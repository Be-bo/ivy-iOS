//
//  TopicCommentCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-03.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class TopicCommentCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var commentAuthorImageView: UIImageView!
    @IBOutlet weak var commentAuthorName: StandardBoldLabel!
    @IBOutlet weak var commentLabel: StandardLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
