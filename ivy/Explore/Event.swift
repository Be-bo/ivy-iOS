//
//  Event.swift
//  ivy
//
//  Created by paul dan on 2019-08-25.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//deals with the logic corresponding to when you actually click on an event

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class Event: UIViewController{
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()             //reference to storage
    
    
    private var eventLogo = UIImageView()                                        //events logo
    var eventDescription = ""

//    var eventDate = UITextView()                                               //from --- to ----. date info
    public var eventID: String?
    public var event = Dictionary<String, Any>()                                 //actual event that was clicked
    public var userProfile = Dictionary<String, Any>()                           //holds the current user profile
    
    
    
    @IBOutlet weak var eventImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindData()
//        if (!self.userProfile.isEmpty && self.eventID != nil) {
//            //TODO: figure out if event count needs to be updated here or not
////            self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("events").document(self.eventID!).updateData(["views": FieldValue.arrayUnion([Date().millisecondsSince1970])]) //update event view count
//            self.bindData()
//        }
    }
    
    
    //populate the front end with the data from the event
    func bindData() {
        
        self.navigationItem.title = self.event["name"] as! String //TODO: put title in top bar. use ivy green: #2b9721
        
        self.baseStorageReference.child(self.event["image"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.eventImage.image  = UIImage(data: data!)
            }
        }
        
        self.baseStorageReference.child(self.event["logo"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.eventLogo.image  = UIImage(data: data!)
            }
        }
        
        self.eventDescription = self.event["description"] as! String
        
        
        
        
        
    }
    
    
    
    
}
