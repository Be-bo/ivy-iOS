//
//  ErrorLabel.swift
//  ivy
//
//  Created by Robert on 2019-07-14.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        self.numberOfLines = 0
        self.textAlignment = .center
        self.font = UIFont(name: "Cordia New", size: 25)
        self.textColor = Colors.ivy_notification
    }
}

