//
//  CardBack.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class CardBack: UIView{
    
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var age: MediumGreenLabel!
    @IBOutlet weak var degree: MediumLabel!
    @IBOutlet weak var bio: StandardLabel!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
