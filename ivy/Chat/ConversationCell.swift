//
//  ConversationCell.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var lastMessage: StandardLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUp(){
        self.img.layer.masksToBounds = true
        self.img.layer.cornerRadius = self.img.bounds.width / 2
    }
}
