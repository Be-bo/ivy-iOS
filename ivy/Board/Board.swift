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

    
    //used for the onclick listeners of the cards themselves
    private var postClicked = Dictionary<String,Any>()                           //used for displaying the website link of the ad posted
    private var postType = ""                                                    //whether itll be an event or an ad
    private var postAuthorId = ""                                                //used to view other person profile from when they click on there profile picture
    private var eventClickedID = ""                                              //id from whatever event they clicked from recent organizations
    private var eventClicked = Dictionary<String,Any>()
    private var convId = ""                                                      //used to get to the conversation when they click on board card
    private var isThisUsersHistory = false                                       //used to indicate if you clicked on  see all posts for yourself, or from someone else
    
    
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
//        boardTableView.allowsSelection = false


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
                                if (index >= (querySnapshot!.count - 1)){
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
        let indexPath = IndexPath(item: 0, section: 0)

        
        if (self.thisUserProfile["last_post_id"] as! String != "" && self.thisUserProfile["last_post_id"] as! String != "null") {
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("boardposts").document(self.thisUserProfile["last_post_id"] as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.thisUsersMostRecentPost = document.data()!
                    //first post is already this user's -> just set the new one and notify the adapter
                    if (self.allPosts.count > 0 && self.allPosts[0]["author_id"] as! String == self.thisUserProfile["id"] as! String){
                        self.allPosts[0] = self.thisUsersMostRecentPost
                        self.boardTableView.reloadRows(at: [indexPath], with: .fade)
                    }else{
                        self.allPosts.insert(self.thisUsersMostRecentPost, at: 0)
                        self.boardTableView.insertRows(at: [indexPath], with: .fade)
                        // Let's see what the tableView claims is the the number of rows.
                    }
                    
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
                            if(index >= (querySnapshot!.count - 1)) {
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
    
    // called for every single cell thats displayed on screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        //for extracting conv id
        var current = self.allPosts[indexPath.row]
        self.convId = ""
        if(!self.friendConvList.isEmpty && self.friendConvList.contains(where: { $0.key == current["author_id"] as? String})){
            let indexFromConvo = current["author_id"] as! String
            self.convId = self.friendConvList[indexFromConvo] as! String
        }
        
        //cell setup
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPostTableViewCell", for: indexPath) as! BoardPostTableViewCell
        cell.setUpBoardPosts(post: self.allPosts[indexPath.row])  //call setup on the cell to populate each cell witht he right information.
        cell.selectionStyle = UITableViewCell.SelectionStyle.none   //make the cells not clickable and highlight grey
        cell.bringSubviewToFront(cell.actionsButton)
        
        
        
        //setup all the click listeners on the cards so they choose the several actions per card
        self.setUpOnClicks(cell: cell, boardPost: self.allPosts[indexPath.row])
        

        
        //pagination
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
            if(!self.loadedAllFriendPosts || !self.loadedAllOrganizationPosts){
                self.obtainBatch(friendQuery: friendQuery!, organizationQuery: organizationQuery!)
            }
        }
        
        
        return cell
    }
    
    //make the profile pic and the post image clickable (if applicable)
    func setUpOnClicks(cell: BoardPostTableViewCell, boardPost:Dictionary<String,Any>) {
        var singleTap = UITapGestureRecognizer(target: self, action: .none)
        self.postType = cell.postType
        self.postClicked = boardPost

        
        //make the profile pic and the post image clickable only if the post hasn't been made by this user themselves.
        if (self.thisUserProfile["id"] as! String != boardPost["author_id"] as! String){
            self.postAuthorId = boardPost["author_id"] as! String    //extract author id for segue to viewing their profile

            
            singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickLogoImageFromBoardPost))
            cell.logoImageView.isUserInteractionEnabled = true
            cell.logoImageView.addGestureRecognizer(singleTap)
            

            
            //if its not a standard post...i.e its an ad or an event, then grab the event object to be able to segue over to event/ad page
            let hasImage = boardPost["has_image"] as! Bool
            if (self.postType != "standard" && hasImage){
//                self.postClicked = boardPost
                self.eventClickedID = boardPost["target_id"] as! String
//                self.postType = cell.postType
                
                //using the event id, extract the event object and then add an onclick listener to the evewnt iamge.
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").document(self.eventClickedID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.eventClicked = document.data()!
                        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickMainImageFromBoardPost))
                        cell.mainPostImage.isUserInteractionEnabled = true
                        cell.mainPostImage.addGestureRecognizer(singleTap)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
        
        //if the post has been made by this user, then show the "my most recent post text" and the "see all posts" on bottom of card, get rid of actions
        if(self.thisUserProfile["id"] as! String == boardPost["author_id"] as! String){
            cell.myMostRecentLabel.isHidden = false
            cell.seeAllPostsLabel.isHidden = false
            cell.actionsButton.isHidden = true
            
            //set on click listener for see all posts which takes them to the see all posts page.
            singleTap = UITapGestureRecognizer(target: self, action: #selector(self.seeAllPosts))
            cell.seeAllPostsLabel.isUserInteractionEnabled = true
            cell.seeAllPostsLabel.addGestureRecognizer(singleTap)
            
            cell.actionsButton.isUserInteractionEnabled = false //non clickable now since there isnt any actions to take on your own post
            cell.logoImageView.isUserInteractionEnabled = false //non clickable since this is this users own profile image
            
            
        }else{  // make the actions button oepn dialogs for the differeing options that can occur per post
            //make the actions button clickable that will display the right actions
            singleTap = UITapGestureRecognizer(target: self, action: #selector(self.showActions))
            cell.actionsButton.isUserInteractionEnabled = true
            cell.actionsButton.addGestureRecognizer(singleTap)
            switch (self.postType) {
                case "standard":
                    print("standard")
                    break
                case "event":
                    print("event")
                    break
                case "ad":
                    print("ad")
                    break
                default:
                    print("default")
                    break
            }
        }
        
    }
    
    
    //used to  show the different actions that can be done per board card
    @objc func showActions() {
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        if self.postType == "standard"{
            actionSheet.addAction(UIAlertAction(title: "message", style: .default, handler: {(alert: UIAlertAction!) in self.gotoConversationWithUser()} ))
            actionSheet.addAction(UIAlertAction(title: "View Profile", style: .default, handler: {(alert: UIAlertAction!) in self.viewProfile()} ))
            actionSheet.addAction(UIAlertAction(title: "See All Posts", style: .default, handler: {(alert: UIAlertAction!) in self.seeAllPosts()}  ))
            actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: {(alert: UIAlertAction!) in self.reportPost()} ))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        if self.postType == "event"{
            actionSheet.addAction(UIAlertAction(title: "View Organization", style: .default, handler: {(alert: UIAlertAction!) in self.viewOrganization()} ))
            actionSheet.addAction(UIAlertAction(title: "View Event", style: .default, handler: {(alert: UIAlertAction!) in self.gotoEvent()} ))
            actionSheet.addAction(UIAlertAction(title: "See All Posts", style: .default, handler: {(alert: UIAlertAction!) in self.seeAllPosts()}  ))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        if self.postType == "ad"{
            actionSheet.addAction(UIAlertAction(title: "View Organization", style: .default, handler: {(alert: UIAlertAction!) in self.viewOrganization()} ))
            actionSheet.addAction(UIAlertAction(title: "View Promotion", style: .default, handler: {(alert: UIAlertAction!) in self.gotoAdd()} ))
            actionSheet.addAction(UIAlertAction(title: "See All Posts", style: .default, handler: {(alert: UIAlertAction!) in self.seeAllPosts()} ))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    //when they click the main board post image, they can either go view the ad or the event
    @objc func clickMainImageFromBoardPost() {
        if (self.postType == "ad"){
            self.gotoAdd()
        }else if (self.postType == "event"){
            self.gotoEvent()
        }
    }
    
    //when they click the logo, they can either view the orgnaization behind the ad/event, or the users profile itself
    @objc func clickLogoImageFromBoardPost() {
        if (self.postType == "ad" || self.postType == "event"){
            self.viewOrganization()
        }else if (self.postType == "standard"){
            self.viewProfile()
        }
    }
    
    
    
    
    //simply open the link in an external browser
    func gotoAdd() {
        let url = URL(string: self.postClicked["ad_link"] as! String)
        UIApplication.shared.open(url!, options: [:])
    }
    
    //segue over to event page
    func gotoEvent() {
        self.performSegue(withIdentifier: "viewEventFromBoardPost" , sender: self) //perform segue to view event
    }
    
    func gotoConversationWithUser() {
        if(self.postType == "standard" && self.convId != ""){
            self.performSegue(withIdentifier: "boardToConversation" , sender: self) //perform segue to view event
        }
    }
    
    func reportPost() {
        //report the post
        var report = Dictionary<String,Any>()
        report["reportee"] = self.thisUserProfile["id"] as! String
        report["report_type"] = "post"
        report["target"] = self.postClicked["id"] as! String
        report["time"] = Date().timeIntervalSince1970
        var reportId = self.baseDatabaseReference.collection("report").document().documentID
        report["id"] = reportId
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.postClicked["id"] as! String).getDocuments() { (querySnapshot, err) in
            if let err = err {
            } else {
                if (!querySnapshot!.isEmpty){
                    //TODO: add front end that displays this print statement
                    print("you have already reported this post")
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    print("The post has been reported")
                    //TODO: add fnt end that displays the error statement
                }
            }
        }

        
        
    }
    
    @objc func seeAllPosts(){
        self.performSegue(withIdentifier: "boardToSeeAllPosts" , sender: self) //perform segue to view event

    }

    func viewProfile() {
        self.performSegue(withIdentifier: "viewProfileFromBoardPost" , sender: self) //perform segue to view event
    }
    
    func viewOrganization() {
        self.performSegue(withIdentifier: "viewOrganizationFromBoardPost" , sender: self) //perform segue to view event
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //when they click on the main image from recent posts an organization has, extract that posts target_id which is the event's id. use event id to pull and send through segue
        if segue.identifier == "viewEventFromBoardPost" {
            let vc = segue.destination as! Event
            vc.event = self.eventClicked
            vc.userProfile = self.thisUserProfile
        }
        if segue.identifier == "viewProfileFromBoardPost" {
            let vc = segue.destination as! ViewFullProfileActivity
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.postAuthorId
        }
        if segue.identifier == "viewOrganizationFromBoardPost" {
            let vc = segue.destination as! organizationPage
            vc.userProfile = self.thisUserProfile
            vc.organizationId = self.postAuthorId
        }
        if segue.identifier == "boardToConversation" {
            let vc = segue.destination as! ChatRoom
            print("conv ID:", self.convId)
            vc.conversationID = self.convId  //pass the user profile object
            vc.thisUserProfile = self.thisUserProfile
        }
        if segue.identifier == "boardToSeeAllPosts" {
            let vc = segue.destination as! boardHistory
            print("conv ID:", self.convId)
            vc.thisUserProfile = self.thisUserProfile
            vc.isThisUsersHistory = self.isThisUsersHistory
            vc.authorID = self.postClicked["author_id"] as! String
            if (self.postType == "standard"){
                vc.authorType = "user"
            }else{
                vc.authorType = "organization"
            }
        }
        
        
        
    }
    

    
    
    
    
}



