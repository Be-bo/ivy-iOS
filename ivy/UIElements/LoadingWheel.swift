//
//  LoadingWheel.swift
//  ivy
//
//  Created by Robert on 2019-06-15.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class LoadingWheel: UIActivityIndicatorView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp(){
        self.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.color = Colors.ivy_green
        self.startAnimating()
    }
    
}
