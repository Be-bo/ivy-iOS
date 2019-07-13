//
//  StandardBoldLabel.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//
import UIKit

class StandardBoldLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        self.font = UIFont(name: "Cordia New", size: 25)?.bold()
        self.textColor = Colors.ivy_grey
    }
}
