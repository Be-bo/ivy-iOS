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
    
    private static let BATCH_SIZE = 5
    private static let NEW_BATCH_TOLERANCE = 1
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    //default queries for both organization and friend posts
    private var defaultFriendQuery: Query? = nil
    private var defaultOrganizationQuery: Query? = nil
    private var lastRetrievedFriendDocument: DocumentSnapshot? = nil
    private var lastRetrievedOrganizationDocument: DocumentSnapshot? = nil
    
    
    private var friendConvList = Dictionary<String,Any>()
    private var thisUserProfile = Dictionary<String, Any>()
    private var thisUsersMostRecentPost = Dictionary<String, Any>() //this users msot recent baord post, always in position 0
    private var thisUni = Dictionary<String,Any>()
    private var firstPost = Dictionary<String,Any>()
    private var allPosts = [Dictionary<String,Any>]()
    private var newPosts = [Dictionary<String,Any>]()
    
    private var batchInProgress = false
    private var loadedAllFriendPosts = false
    private var loadedAllOrganizationPosts = false

    
    @IBOutlet var boardTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        configureTableView()
        setUp()
        
//        updateProfile(updatedProfile: self.thisUserProfile) //load the profile then call setup from there
    }
    

    
    func configureTableView(){

        boardTableView.delegate = self
        boardTableView.dataSource = self
        boardTableView.register(UINib(nibName: "BoardPostTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardPostTableViewCell")
        boardTableView.estimatedRowHeight = 200


    }
    
    func setUp() {
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    if (document.data()!.contains(where: { $0.key == "main_organization_id"})){
                        self.thisUni = document.data()!
                        self.getFriendList()
                        self.getInitialData()
                    }
                } else {
                    print("Document does not exist HERE21")
                }
            }
            
        }
    }
    
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        self.thisUserProfile = updatedProfile
    }
    
    
    //get users last post (if exist), then get all this users friends post (limit = batch_size)
    func getInitialData() {
        //set up default queries for both organization and friend posts
        self.defaultFriendQuery = self.baseDatabaseReference.collectionGroup("boardposts").whereField("friend_ids", arrayContains: self.thisUserProfile["id"] as! String).order(by: "time_millis", descending: true).limit(to: Board.BATCH_SIZE)
        self.defaultOrganizationQuery = self.baseDatabaseReference.collection("organizations").document(self.thisUni["main_organization_id"] as! String).collection("boardposts").order(by: "time_millis", descending: true).limit(to: Board.BATCH_SIZE)
        self.setMostRecentPost()
        self.obtainBatch(friendQuery: self.defaultFriendQuery!, organizationQuery: self.defaultOrganizationQuery!)
    }
    
    
    //obtain all of the most recent posts across this user's friends (limited to the given batch size)
    func obtainBatch(friendQuery:Query, organizationQuery: Query) {
        batchInProgress = true
        self.newPosts = []  //empty array list for new batch
        
        friendQuery.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("error: \(err)")
            } else {
                
                
                if (!self.loadedAllFriendPosts){
                    
                    if (!querySnapshot!.isEmpty){
                        
                        for (index, document) in querySnapshot!.documents.enumerated() {
                                var newPost = document.data()
                                //if the new post is non null and this user isn't its author
                                if (!newPost.isEmpty && newPost["author_id"] as! String != self.thisUserProfile["id"] as! String){
                                    self.newPosts.append(newPost)
                                }
                                if (index > (querySnapshot!.count - 1)){
                                    self.lastRetrievedFriendDocument = document
                                }
                            }
                    }else{
                        self.loadedAllFriendPosts = true
                    }
                }
                self.getCampusBodyBoardPosts(organizationQuery: organizationQuery)
            }
        }
    }
    
    
    
    //update users most recent post
    func setMostRecentPost() {
        //for reloading specific idnex of table view
        
        
        if (self.thisUserProfile["last_post_id"] as! String != "" && self.thisUserProfile["last_post_id"] as! String != "null") {
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("boardposts").document(self.thisUserProfile["last_post_id"] as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.thisUsersMostRecentPost = document.data()!
                    //first post is already this user's -> just set the new one and notify the adapter
                    if (self.allPosts.count > 0 && self.allPosts[0]["author_id"] as! String == self.thisUserProfile["id"] as! String){
                        self.allPosts[0] = self.thisUsersMostRecentPost
                        //self.boardTableView.reloadRows(at: [indexPosition], with: .none)
                    }else{
                        self.allPosts.insert(self.thisUsersMostRecentPost, at: 0)
                        //self.boardTableView.reloadRows(at: [indexPosition], with: .none)
                    }
                    
                    //self.boardTableView.reloadData()
                    //hideLoadingElems()  TODO: decide if we need the stop loading animation and make the recycler view visible
                } else {
                    print("Document does not exist")
                }
            }
        }
        

        
        
        
        
    }
    
    

    
    //add the main campus body's Boards posts
    func getCampusBodyBoardPosts(organizationQuery: Query) {
        
        organizationQuery.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if (!self.loadedAllOrganizationPosts){
                    

                    if (!querySnapshot!.isEmpty){
                        for (index,document) in querySnapshot!.documents.enumerated(){
                            let newPost = document.data()
                            if (!newPost.isEmpty ){
                                self.newPosts.append(newPost)
                            }
                            if(index > (querySnapshot!.count - 1)) {
                                self.lastRetrievedOrganizationDocument = document
                            }
                            
                        }
                        
                    }else{
                        self.loadedAllOrganizationPosts = true
                    }

                    
//                    TODO: decide if sorting actually needs to be done or not here
//                    self.newPosts.sorted(by: { $0["time_millis"]as! CLong > $1["time_millis"]as! CLong })
                    
                    self.allPosts.append(contentsOf: self.newPosts)
                    //                hideLoadingElems() //TODO: decide if we need the stop loading animation and make the recycler view visible
                    self.batchInProgress = false
                    self.boardTableView.reloadData()
                }
                
                
            }
        }
        
    }
    
    
    
    func getFriendList() {
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                self.friendConvList = document.data()!
                //TODO: setup  onclick listener for the "+" button that allows a person to create post
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    // MARK: TableView Methods

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPosts.count    //recentposts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        
        var current = self.allPosts[indexPath.row]
        var convId = ""
        
        if(!self.friendConvList.isEmpty && self.friendConvList.contains(where: { $0.key == "author_id"})){
            convId = self.friendConvList["author_id"] as! String
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPostTableViewCell", for: indexPath) as! BoardPostTableViewCell
        cell.setUp(post: self.allPosts[indexPath.row])  //call setup on the cell to populate each cell witht he right information.
        
        
        
        if (!self.batchInProgress && indexPath.item >= (self.allPosts.count - Board.NEW_BATCH_TOLERANCE)) {
            var friendQuery: Query? = nil
            var organizationQuery: Query? = nil
        
            if(self.lastRetrievedOrganizationDocument != nil){
                organizationQuery = self.defaultOrganizationQuery?.start(afterDocument: self.lastRetrievedOrganizationDocument! )
            }else{
                organizationQuery = self.defaultOrganizationQuery
            }
            
            if(self.lastRetrievedFriendDocument != nil){
                friendQuery = self.defaultFriendQuery?.start(afterDocument: self.lastRetrievedFriendDocument! )
            }else{
                friendQuery = self.defaultFriendQuery
            }
            
            print("loaded friends", self.loadedAllFriendPosts, "loaded org", self.loadedAllOrganizationPosts)
            
            if(!self.loadedAllFriendPosts || !self.loadedAllOrganizationPosts){
                self.obtainBatch(friendQuery: friendQuery!, organizationQuery: organizationQuery!)
            }
            
            
        }
        
        
        return cell
    }
    

    
    
    
    
}



