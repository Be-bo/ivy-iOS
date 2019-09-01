//
//  StandardButton.swift
//  ivy
//
//  Created by Robert on 2019-06-15.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class StandardButton: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        setShadow()
        self.backgroundColor = Colors.ivy_green
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Cordia New Bold", size: 25)
        self.layer.cornerRadius = 5
    }
    
    
    private func setShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.clipsToBounds = true
        self.layer.masksToBounds = false
    }
}
