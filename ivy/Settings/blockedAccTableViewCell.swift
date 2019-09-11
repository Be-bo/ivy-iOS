//
//  blockedAccTableViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class blockedAccTableViewCell: UITableViewCell {

    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database

    
    //passed through settings segue
    var thisUserProfile = Dictionary<String, Any>()
    var userToUnblock = Dictionary<String,Any>()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var unblockUserButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUp(user: Dictionary<String,Any>, thisUserProfile: Dictionary<String,Any>, previousVC: BlockedAccounts ) {
    
        self.thisUserProfile = thisUserProfile
        self.userToUnblock = user
        if let id = user["id"] as? String{
            let previewPicRef = "userimages/"+id+"/preview.jpg"
            baseStorageReference.child(previewPicRef).getData(maxSize: 2 * 1024 * 1024) { (data, e) in //get user's preview pic
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    if let dat = data, let userFirstName = user["first_name"] as? String, let userLastName = user["last_name"] as? String{ //and set it as well as their name
                        self.profileImageView.image = UIImage(data: dat)
                        let userFullName = userFirstName + " " + userLastName
                        self.nameLabel.text = userFullName
                    }
                }
            }
        }
    }
}
