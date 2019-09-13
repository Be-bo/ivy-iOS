//
//  ConversationCell.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class ConversationCell: UITableViewCell {
    
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var thisConversation = Dictionary<String, Any>()
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var lastMessage: StandardLabel!
    @IBOutlet weak var groupSymbol: UIImageView!
    @IBOutlet weak var reject: UIButton!
    @IBOutlet weak var accept: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUp(){
        self.lastMessage.numberOfLines = 1
        self.img.layer.masksToBounds = true
        self.img.layer.cornerRadius = self.img.bounds.width / 2
        self.groupSymbol.isHidden = true    //group symbol hidden by default
        self.accept.isHidden = true
        self.reject.isHidden = true
    }
    
    func hideRequestLayout() {
        accept.isHidden = true
        reject.isHidden = true
    }
    
    func showRequestLayout(){
        accept.isHidden = false
        reject.isHidden = false
    }
    
    
    //populate the data that will need to actually accept or reject the request
    func setInfo(thisConversation:Dictionary<String, Any>, thisUserProfile:Dictionary<String, Any>){
        self.thisUserProfile = thisUserProfile
        self.thisConversation = thisConversation
    }
}
