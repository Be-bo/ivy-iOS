//
//  TopicAddCommentCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-27.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class TopicAddCommentCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var addCommentAuthorImage: UIImageView!
    @IBOutlet weak var addCommentTextField: UITextField!
    @IBOutlet weak var addCommentSubmitButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    @IBAction func beginEditingTextField(_ sender: Any) {
        addCommentSubmitButton.isHidden = false
    }
    
    
    @IBAction func doneEditing(_ sender: Any) {
        addCommentSubmitButton.isHidden = true
        
    }
    
    


}




