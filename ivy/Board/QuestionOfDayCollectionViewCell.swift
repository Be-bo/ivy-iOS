//
//  QuestionOfDayCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-26.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class QuestionOfDayCollectionViewCell: UICollectionViewCell {

        
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var numberViewingLabel: UILabel!
    @IBOutlet weak var commentLabel: StandardLabel!
    @IBOutlet weak var viewHoldingBottonBit: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
