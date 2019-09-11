//
//  AddParticipantTableViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-09-10.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

class AddParticipantTableViewCell: UITableViewCell {

    private var thisUserProfile = Dictionary<String, Any>()
    private var thisConversation = Dictionary<String, Any>()
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nameLabel: StandardLabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(){
        self.img.layer.masksToBounds = true
        self.img.layer.cornerRadius = self.img.bounds.width / 2
    }
    
}
