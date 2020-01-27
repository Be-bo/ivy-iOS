//
//  ExploreLabel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-01-26.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit
import Foundation

class ExploreLabel: UILabel{
    
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
        self.font = UIFont(name: "Cordia New", size: 35)?.bold()
        self.textColor = UIColor.black
    }
}
