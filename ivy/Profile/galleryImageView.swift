//
//  galleryImageView.swift
//  ivy
//
//  Created by paul dan on 2019-09-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class galleryImageView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    @IBOutlet weak var imageView: UIImageView!
    var isProfileImage = false  //false by default
    var pictureReference = ""   //reference to storage of the picture
    
    
}
