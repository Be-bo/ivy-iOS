//
//  EventCollectionViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-08-25.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//class that deals with the logic corresponding to the ccell that displays events in the explroe tab and "recent posts" events also

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class EventCollectionViewCell: UICollectionViewCell {

    private let baseStorageReference = Storage.storage().reference()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setUp(event: Dictionary<String, Any>){
        
        var imageLocation = ""
        
        if let imagePath = event["image"] as? String{
            imageLocation = imagePath
        }
        
        let storageImageRef = baseStorageReference.child(imageLocation)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.image.image  = UIImage(data: data!)
                self.nameLabel.text = event["name"] as! String
            }
        }
        
        
    }
    
    
    

}
