//
//  ProfileCardFront.swift
//  ivy
//
//  Created by paul dan on 2019-09-01.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ProfileCardFront: UIView {
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var flipButton: OpacityButton!
    @IBOutlet weak var galleryButton: OpacityButton!
    
    
    
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
    
    func setUpInterests(){
        
    }
}
