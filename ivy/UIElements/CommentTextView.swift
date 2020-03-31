//
//  CommentTextField.swift
//  ivy-iOS
//
//  Created by Robert on 2020-03-30.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class CommentTextView: UITextView{
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        self.textColor = UIColor.ivyHint
        self.font = UIFont(name: "Cordia New", size: 25)
    }
}

