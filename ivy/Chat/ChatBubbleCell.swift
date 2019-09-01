//
//  ChatBubbleCell.swift
//  ivy
//
//  Created by Robert on 2019-09-01.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ChatBubbleCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorName: StandardLabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var messageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
