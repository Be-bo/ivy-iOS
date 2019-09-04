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
    public var thisUserProfile = Dictionary<String, Any>()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var unblockUserButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var userToUnblock = Dictionary<String,Any>()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setUp(user: Dictionary<String,Any>, thisUserProfile: Dictionary<String,Any>) {
    
        self.thisUserProfile = thisUserProfile
        self.userToUnblock = user

        
        if let ref = user["profile_picture"] as? String{ //profile picture
            baseStorageReference.child(ref).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    self.profileImageView.image = UIImage(data: data!)
                    let userFirstName = user["first_name"] as! String
                    let userLastName = user["last_name"] as! String
                    let userFullName = userFirstName + userLastName
                    self.nameLabel.text = userFullName
                    //TODO: start here when come back and try switching the label to be a regular label.
                }
            }
        }
        
    }
    
    
    @IBAction func clickUnblockUser(_ sender: Any) {
        unblockUser()
    }

    
    //remove this user's id from the "blocked_by" list of the blocked user and also remove blocker user's id from this user's "block_list", and update the adapter
    func unblockUser() {

//        print("user to unblock", self.userToUnblock)
        print("this user profile", self.thisUserProfile)


        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").updateData([self.userToUnblock["id"] as! String: FieldValue.delete()])

        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.userToUnblock["id"] as! String).collection("userlists").document("blocked_by").updateData([self.thisUserProfile["id"] as! String: FieldValue.delete()], completion: { (error) in
            if error != nil {
            } else {
                //TODO: remove the cell from the table view
                //TODO: reload the tableview
            }
        })


    }
    
}
