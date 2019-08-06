//
//  CardInterestCell.swift
//  ivy
//
//  Created by Robert on 2019-08-06.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class CardInterestCell: UICollectionViewCell {

    @IBOutlet weak var interestLabel: StandardLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp(){
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.ivyGrey.cgColor
    }

}
