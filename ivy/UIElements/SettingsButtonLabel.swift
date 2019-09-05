//
//  SettingsButtonLabel.swift
//  ivy
//
//  Created by paul dan on 2019-09-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Foundation

class SettingsButtonLabel: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = UIFont(name: "Cordia New", size: 25)
    }
    
    
    
}
