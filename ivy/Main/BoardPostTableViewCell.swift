//
//  BoardPostTableViewCell.swift
//  ivy
//
//  Created by paul dan on 2019-08-27.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


class BoardPostTableViewCell: UITableViewCell {

    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                                   //reference to the database
    
    public var postType = ""                                        //type of board post, whether event, or ad
    public var organizationId = ""
    
    
    @IBOutlet weak var logoImageView: UIImageView!                  //logo in top left
    @IBOutlet weak var postTitle: UILabel!                          //right beside logo -- title
    @IBOutlet weak var postDescription: UILabel!                    //display several actions that can be done per card
    @IBOutlet weak var mainPostImage: UIImageView!
    @IBOutlet weak var actionsButton: UIButton!                     //either event's description or persons post desc
    @IBOutlet var myMostRecentLabel: UILabel!
    @IBOutlet var seeAllPostsLabel: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
    //setup the cell with the certain post fromthe organization
    func setUpBoardPosts(post: Dictionary<String,Any>){
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.ivyGreen.cgColor
        
        self.bringSubviewToFront(self.actionsButton)//TODO: maybe get rid of this line if ti works fine without
        self.actionsButton.isHidden = false  //hidden when its a recent post from an organization
        self.postTitle.text = post["name"] as? String
        self.postDescription.text = post["text"] as? String
        self.postType = post["type"] as! String
        
        //hidden by default and determined fro board if to show or not
        self.myMostRecentLabel.isHidden = true
        self.seeAllPostsLabel.isHidden = true
        
        //logo
        var imageLocation = post["preview_image"] as! String
        var storageImageRef = self.baseStorageReference.child(imageLocation)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.logoImageView.image = UIImage(data: data!)
            }
        }
        
        //main post image, make sure it has a post image though, else dont populate it
        let bool = post["has_image"] as! Bool
        if (bool == true) {
            self.mainPostImage.isHidden = false
            imageLocation = post["post_image"] as! String
            storageImageRef = self.baseStorageReference.child(imageLocation)
            storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.mainPostImage.image = UIImage(data: data!)
                }
            }
        }else{//doesn't have a post image, so just hide that field
            self.mainPostImage.isHidden = true
        }
        
        
        
        
        
        
        
    }
    
    //setup the cell with the certain post fromthe organization
    func setUpEventRecentPosts(post: Dictionary<String,Any>){
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.ivyGreen.cgColor
        
        //"my most recent post" && "see all posts" hidden by default when its an organizations posts
        self.myMostRecentLabel.isHidden = true
        self.seeAllPostsLabel.isHidden = true
        
        
        self.actionsButton.isHidden = true  //hidden when its a recent post from an organization
        self.postTitle.text = post["name"] as? String
        self.postDescription.text = post["text"] as? String
        self.postType = post["type"] as! String
        
        //logo
        var imageLocation = post["preview_image"] as! String
        var storageImageRef = self.baseStorageReference.child(imageLocation)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.logoImageView.image = UIImage(data: data!)
            }
        }
        
        //main post image, make sure it has a post image though, else dont populate it
        let bool = post["has_image"] as! Bool
        if (bool == true) {
            self.mainPostImage.isHidden = false
            imageLocation = post["post_image"] as! String
            storageImageRef = self.baseStorageReference.child(imageLocation)
            storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.mainPostImage.image = UIImage(data: data!)
                }
            }
        }else{//doesn't have a post image, so just hide that field
            self.mainPostImage.isHidden = true
        }
        
    }
    
    
    
    
    
    

    
    
    
}
