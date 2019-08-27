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
    private let baseDatabaseReference = Firestore.firestore()                                   //reference to the database

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = UIColor.blue
        // Initialization code
    }
    
    
    func setUp(userGoingId: String, thisUserProfile:Dictionary<String, Any>){
       
        //extract the user profile from user going id. Use that profile to populate the corresponding cell information
        self.baseDatabaseReference.collection("universities").document(thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(userGoingId).getDocument { (document, error) in
            if let document = document, document.exists {
                var userGoingProfile = document.data() //user profile just extracted
              
                let imageLocation = "userimages/" + userGoingId + "/preview.jpg"
                let storageImageRef = self.baseStorageReference.child(imageLocation)
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        print("else")
                        self.name.text = userGoingProfile!["first_name"] as? String
                        self.imageView.image = UIImage(data: data!)
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
