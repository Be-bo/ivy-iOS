//
//  profileCollectionViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-08-26.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//class that deals with the logic corresponding to the ccell that displays users profiles in "whos going" and "recommended friends"

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


class profileCollectionViewCell: UICollectionViewCell {
    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()
    var profile = Dictionary<String, Any>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadingWheel.startAnimating()
    }
    
    
    func setUp(userGoingId: String, thisUserProfile:Dictionary<String, Any>){
        if let userUniDomain = thisUserProfile["uni_domain"] as? String {
            //extract the user profile from user going id. Use that profile to populate the corresponding cell information
            self.baseDatabaseReference.collection("universities").document(userUniDomain).collection("userprofiles").document(userGoingId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let userGoingProfile = document.data() //user profile just extracted
                    let imageLocation = "userimages/" + userGoingId + "/preview.jpg"
                    let storageImageRef = self.baseStorageReference.child(imageLocation)
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            self.name.text = userGoingProfile!["first_name"] as? String //userGoingProfile doesn't need to be unwrapped since the doc data was unwrapped above and thus will exist
                            self.loadingWheel.stopAnimating()
                            self.loadingWheel.isHidden = true
                            self.imageView.image = UIImage(data: data!)
                            self.imageView.isHidden = false
                            self.imageView.layer.borderWidth = 1.0
                            self.imageView.layer.masksToBounds = false
                            self.imageView.layer.borderColor = UIColor.white.cgColor
                            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                            self.imageView.clipsToBounds = true
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    func setUpWithProfile(profile: Dictionary<String, Any>){
        self.profile = profile
        if let profileID = profile["id"] as? String {
            let imageLocation = "userimages/" + String(profileID) + "/preview.jpg"
            let storageImageRef = baseStorageReference.child(imageLocation)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.imageView.image  = UIImage(data: data!)    //data exists here no need to for unwrap
                    self.loadingWheel.stopAnimating()
                    self.loadingWheel.isHidden = true
                    self.imageView.isHidden = false
                    self.name.text = profile["first_name"] as? String
                }
            }

        }
    }
    
    
    
    
    
    
    

}
