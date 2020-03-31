//
//  TopicAddCommentCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-27.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class TopicAddCommentCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    
    @IBOutlet weak var addCommentAuthorImage: UIImageView!
    @IBOutlet weak var addCommentSubmitButton: UIButton!
    @IBOutlet weak var addCommentTextView: UITextView!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addCommentTextView.delegate = self
    }
    
    func showButton(){
        if(!addCommentSubmitButton.isEnabled){
            buttonHeightConstraint.constant = 50
            addCommentSubmitButton.isEnabled = true
            addCommentSubmitButton.isHidden = false
        }
    }
}




