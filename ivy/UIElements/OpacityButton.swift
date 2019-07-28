//
//  OpacityButton.swift
//  ivy
//
//  Created by Robert on 2019-07-27.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class OpacityButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        self.backgroundColor = UIColor.ivyButtonOpacity
        self.layer.cornerRadius = 5
    }
}
