//
//  Board.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


class Board: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private static let BATCH_SIZE = 20
    
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var thisUni = Dictionary<String,Any>()
    private var firstPost = Dictionary<String,Any>()
    private var allPosts = [Dictionary<String,Any>]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setUpNavigationBar()
    }
    

    
    func configureTableView(){

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "BoardPostTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardPostTableViewCell")
        tableView.estimatedRowHeight = 200
        
        updateProfile(updatedProfile: self.thisUserProfile) //load the profile then call setup from there

    }
    
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
    }
    
    
    
    
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    if (document.data()!.contains(where: { $0.key == "main_organization_id"})){
                        self.thisUni = document.data()!
                        self.getAllPosts()
                    }
                } else {
                    print("Document does not exist HERE21")
                }
            }

        }
    }
    
    //first get either this user's last post (if it exists) and then get all of this user's friends' posts limited to the given batch size
    func getAllPosts() {
        if (self.thisUserProfile.contains(where: { $0.key == "last_post_id"}) && self.thisUserProfile["last_post_id"] as! String != "" ){
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("boardposts").document(self.thisUserProfile["last_post_id"] as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    let thisUsersLastPost = document.data()
                    self.firstPost = thisUsersLastPost!  //save users most recent post
                    //TODO: figure out why can't reload data
                    //self.tableView.reloadData()
                } else {
                    print("Document does not exist12")
                }
                self.getFriendPosts()
            }
        }else{
            self.getFriendPosts()
        }
    }
    
    //obtain all of the most recent posts across this user's friends (limited to the given batch size)
    func getFriendPosts() {
        self.baseDatabaseReference.collectionGroup("boardposts").whereField("friend_ids", arrayContains: self.thisUserProfile["id"] as! String).order(by: "time_millis", descending: true).limit(to: Board.BATCH_SIZE).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let currentFriendPost = document.data()
                    if (!currentFriendPost.isEmpty){
                        self.allPosts.append(currentFriendPost)
                    }
                }
            }
            self.getCampusBodyBoardPosts()
        }
    }
    
    
    //add the main campus body's Boards posts
    func getCampusBodyBoardPosts() {
        
        self.baseDatabaseReference.collection("organizations").document(self.thisUni["main_organization_id"] as! String).collection("boardposts").order(by: "time_millis", descending: true).limit(to: Board.BATCH_SIZE).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let currentOrgPost = document.data()
                    if (!currentOrgPost.isEmpty){
                        self.allPosts.append(currentOrgPost)
                    }
                }
            }
            
            //TODO: decide if sorting actually needs to be done or not here
            //self.allPosts.sorted(by: { $0["time_millis"]as! CLong > $1["time_millis"]as! CLong })
            
            if (!self.firstPost.isEmpty){
                self.allPosts.insert(self.firstPost, at: 0)
            }
            
            //TODO:ROBERT please help
            //TODO: figure out why can't reload data
            self.tableView.reloadData()
        }

    }
    
    
    
    // MARK: TableView Methods

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPosts.count    //recentposts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPostTableViewCell", for: indexPath) as! BoardPostTableViewCell
 
        cell.setUp(post: self.allPosts[indexPath.item])  //call setup on the cell to populate each cell witht he right information.
        
        
        return cell
    }
    

    
    
    
    
}
