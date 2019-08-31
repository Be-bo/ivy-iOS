//
//  boardHistory.swift
//  ivy
//
//  Created by paul dan on 2019-08-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//
//this  is the class that handles the log logic for when a person chooses to see all the existing posts that an organization/event/person has

import UIKit
import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


class boardHistory: UIViewController, UITableViewDelegate, UITableViewDataSource{

    public var thisUserProfile = Dictionary<String, Any>()      //passse through seg
    public var authorID = ""            //id of the author of the post
    public var allPosts = [Dictionary<String,Any>]()
    public var isThisUsersHistory:Bool = false                      //to indicate that your looking at your own posts in history
    public var authorType = ""                                 //"user" or "organization"
    private var authorProfile = Dictionary<String,Any>()            //profile of the post author
    
    private var defaultQuery:Query? = nil
    private static let BATCH_SIZE = 5
    private static let NEW_BATCH_TOLERANCE = 1
    
    private var batchInProgress = false
    private var allPostsLoaded = false
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: set title of nav bar to be the name of the author
        getData()
        
        //this should be done after getData is finished so we have the profile of the post of the author
        if (self.authorType == "user"){
            self.batchInProgress = true
            self.defaultQuery = self.baseDatabaseReference.collection("universities").document(self.authorProfile["uni_domain"] as! String).collection("userprofiles").document(self.authorProfile["id"] as! String).collection("boardposts").order(by: "time_millis", descending: true).limit(to: boardHistory.BATCH_SIZE)
            obtainBatch(defaultQuery:self.defaultQuery!)
        }else if (self.authorType == "organization"){
            self.batchInProgress = true
            self.defaultQuery = self.baseDatabaseReference.collection("organizations").document(self.authorProfile["id"] as! String).collection("boardposts").order(by: "time_millis", descending: true).limit(to: boardHistory.BATCH_SIZE)
            obtainBatch(defaultQuery:self.defaultQuery!)
        }
        
    }
    
    
    
    
    //get the author profile of the board post
    func getData() {
        if (self.authorID != "" && !self.thisUserProfile.isEmpty && self.authorType != "" ){
            if (!isThisUsersHistory && self.authorType == "user"){
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.authorID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.authorProfile = document.data()!
                        //TODO setupUI
                    } else {
                        print("Document does not exist")
                    }
                }
            }else if (!isThisUsersHistory && self.authorType == "organization"){
                self.baseDatabaseReference.collection("organizations").document(self.authorID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.authorProfile = document.data()!
                        //TODO: TODO setupUI
                    } else {
                        print("Document does not exist")
                    }
                }
            }else{
                //TODO setupUIz
            }
        }else{
            //TODO: show the user that error message on the screen
            print("Something went wrong. Try restarting the app")
        }
    }
    
    //get a single batch of posts
    //TODO: start here when returning to setting up the board.
    func obtainBatch(defaultQuery: Query) {
        self.batchInProgress = true
        defaultQuery.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    
                    
                }
                
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPosts.count    //recentposts.count
    }
    
    // called for every single cell thats displayed on screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        //cell setup
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPostTableViewCell", for: indexPath) as! BoardPostTableViewCell
        cell.setUpEventRecentPosts(post: self.allPosts[indexPath.row])  //call setup on the cell to populate each cell witht he right information.

    
        return cell
    }
    
    
    
}

