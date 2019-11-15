//
//  CardFront.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class CardFront: UIView {
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: MediumLabel!
    @IBOutlet weak var degreeIcon: UIImageView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    
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
