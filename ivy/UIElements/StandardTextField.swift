//
//  StandardTextField.swift
//  ivy
//
//  Created by Robert on 2019-06-15.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class StandardTextField: UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        setShadow()
        self.textColor = Colors.ivy_hint
        self.font = UIFont(name: "Cordia New", size: 25)
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 1
        self.layer.borderColor = Colors.ivy_light_grey.cgColor
        self.layer.cornerRadius = 5
    }
    
    private func setShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
        self.clipsToBounds = true
        self.layer.masksToBounds = false
    }
}
