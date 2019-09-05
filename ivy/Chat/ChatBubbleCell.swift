//
//  ChatBubbleCell.swift
//  ivy
//
//  Created by Robert on 2019-09-01.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore

class ChatBubbleCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var messageContainer: UIView!
    
    let baseStorageReference = Storage.storage()        //reference to storage

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageLabel.numberOfLines = 0
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    func setup(message: Dictionary<String, Any>, thisUserProfile:Dictionary<String,Any>){
//
//        let lastMessageSenderID = message["author_id"] as! String //the author of the last message that was sent
//        var lastMessageAuthor = ""
//        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
//        
//
//        lastMessageAuthor =  message["author_first_name"] as! String //first name of last message author
//        authorProfilePicLoc = "userimages/" + String(message["author_id"] as! String) + "/preview.jpg"
//
//        // Create a storage reference from our storage service
//        let lastMessage = message["message_text"] as! String
//        let storageRef = self.baseStorageReference.reference()
//        let storageImageRef = storageRef.child(authorProfilePicLoc)
//        let lastMessageString = lastMessageAuthor + ": " + lastMessage //last message is a combination of who sent it attached with what message they sent.
//
//        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("error", error)
//            } else {
//                self.messageLabel.text = lastMessageString  //last message that was sent in the chat
//                if(message["author_id"] as! String == thisUserProfile["id"] as! String){
//                    self.profilePicture.isHidden = true
//                    self.messageContainer.backgroundColor = UIColor.ivyGreen
//                }else{
//                    self.profilePicture.isHidden = false
//                    self.messageContainer.backgroundColor = UIColor.ivyGrey
//                    //actually populate the cell data, done here to avoid returning the cell before the document data is pulled async
//                    self.profilePicture.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
//                }
//            }
//        }
//
//
//    }
    
}
