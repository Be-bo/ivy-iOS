//
//  chatBubbleCollectionViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-09-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class chatBubbleCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
