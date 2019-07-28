//
//  ConversationCell.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ConversationCell: UIView {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var lastMessage: StandardLabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    func setUp(){
        self.img.layer.masksToBounds = true
        self.img.layer.cornerRadius = self.img.bounds.width / 2
    }
}
