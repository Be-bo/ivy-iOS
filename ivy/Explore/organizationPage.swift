//
//  organizationPage.swift
//  ivy
//
//  Created by paul dan on 2019-08-26.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class organizationPage: UIViewController /*, UITableViewDelegate, UITableViewDataSource*/ {
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()             //reference to storage
    private var thisOrganization = Dictionary<String,Any>()
    private static let LIMIT = 3                                                 //# fof recent posts to load
    private var allOrgPosts = [Dictionary<String,Any>]()                           //all the posts this organization has
    
    //passed from segue
    public var userProfile = Dictionary<String,Any>()
    public var organizationId = ""
    
    //used for recent posts to either org, or ad
    private var postClicked = Dictionary<String,Any>()                           //used for displaying the website link of the ad posted
    private var postType = ""                                                    //whether itll be an event or an ad
    private var eventClickedID = ""                                              //id from whatever event they clicked from recent organizations
    private var eventClicked = Dictionary<String,Any>()
    
    @IBOutlet weak var recentPostsLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var hyperlinkLabel: UILabel!
    @IBOutlet weak var organizationDescription: UILabel!
    @IBOutlet weak var organizationName: MediumGreenLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureTableView()
        loadOrganizationInfo()
    }
    
    
    func bindData() { //populate the page with the corresponding information that we want and set up a clickable link for the organization's website
        let attributedString = NSMutableAttributedString(string: self.thisOrganization["website"] as! String)
        let url = URL(string: self.thisOrganization["website"] as! String)
        attributedString.setAttributes([.link: url], range: NSMakeRange(0, String(self.thisOrganization["website"] as! String).count))
        hyperlinkLabel.attributedText = attributedString  
        hyperlinkLabel.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickLink))
        hyperlinkLabel.addGestureRecognizer(singleTap)
        
        if let orgName = self.thisOrganization["name"] as? String{ //set up the name of the org as this VC's title
            setUpNavigationBar(orgName: orgName)
        }
        
        if let mission = self.thisOrganization["mission_statement"] as? String{ //set the mission statement if it exists
                organizationDescription.text = "\"" + mission + "\""
        }
        
        if let logoRef = self.thisOrganization["logo"] as? String{
            self.baseStorageReference.child(logoRef).getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.titleImageView.image  = UIImage(data: data!) //set the logo
                }
            }
        }
    }
    
    @objc func clickLink() {
        let url = URL(string: self.thisOrganization["website"] as! String)
        UIApplication.shared.open(url!, options: [:])
    }
    
    func loadOrganizationInfo() { //from the organization id, actually load the organization object
        if (organizationId != ""){
            self.baseDatabaseReference.collection("organizations").document(organizationId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.thisOrganization = document.data()!
//                    self.loadOrgRecentPosts()
                    self.bindData()
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func setUpNavigationBar(orgName: String){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        titleView.text = orgName.uppercased()
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
    }
    
    
    
    //load all the recent posts this organization has to then populate each table view cell with the corresponding information.
//    func loadOrgRecentPosts() {
//
//        self.baseDatabaseReference.collection("organizations").document(self.thisOrganization["id"] as! String).collection("boardposts").order(by: "time_millis", descending: true).limit(to: organizationPage.LIMIT).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                self.recentPostsLabel.isHidden = true            //hide recent psots label since there isn't any recent psots to show
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    if (!document.data().isEmpty){
//                        self.allOrgPosts.append(document.data())
//                    }
//                }
//                self.tableView.reloadData()
//            }
//        }
//
//
//
//    }
//
//
//
//    // MARK: TableView Methods
//
//    func configureTableView(){
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "BoardPostTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardPostTableViewCell")
////        tableView.rowHeight = UITableView.automaticDimension
////        tableView.estimatedRowHeight = 300
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.allOrgPosts.count    //recentposts.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPostTableViewCell", for: indexPath) as! BoardPostTableViewCell
//
//        cell.setUpEventRecentPosts(post: self.allOrgPosts[indexPath.row])  //call setup on the cell to populate each cell witht he right information.
//
//        self.setUpOnClicks(cell: cell, post:self.allOrgPosts[indexPath.row])
//
//        return cell
//    }
//
//
//
//
//    //make the profile pic and the post image clickable (if applicable)
//    func setUpOnClicks(cell: BoardPostTableViewCell, post:Dictionary<String,Any>) {
//
//        if (self.userProfile["id"] as! String != post["id"] as! String){
//
//            //if the post's advertising an event or an ad make the post image clickable to take you to the logical destination (ad link or event page)
//            let hasImage = post["has_image"] as! Bool
//            if (self.postType != "standard" && hasImage){
//                self.postClicked = post
//                self.eventClickedID = post["target_id"] as! String
//                self.postType = cell.postType
//
//                //using the event id, extract the event object and then add an onclick listener to the evewnt iamge.
//                self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("events").document(self.eventClickedID).getDocument { (document, error) in
//                    if let document = document, document.exists {
//                        self.eventClicked = document.data()!
//                        var singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickMainImageFromRecentBoardPost))
//                        cell.mainPostImage.isUserInteractionEnabled = true
//                        cell.mainPostImage.addGestureRecognizer(singleTap)
//                    } else {
//                        print("Document does not exist")
//                    }
//                }
//            }
//
//        }
//
//    }
//
//
//    @objc func clickMainImageFromRecentBoardPost() {
//        if (self.postType == "ad"){
//            self.gotoAdd()
//        }else if (self.postType == "event"){
//            self.gotoEvent()
//        }
//    }
//
//
//    func gotoAdd() {
//        let url = URL(string: self.postClicked["ad_link"] as! String)
//        UIApplication.shared.open(url!, options: [:])
////        self.performSegue(withIdentifier: "viewAdFromOrgPageRecPost" , sender: self) //perfrom segue to view ad
//    }
//
//    func gotoEvent() {
//        self.performSegue(withIdentifier: "viewEventFromOrgPageRecPost" , sender: self) //perform segue to view event
//    }
//
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        //when they click on the main image from recent posts an organization has, extract that posts target_id which is the event's id. use event id to pull and send through segue
//        if segue.identifier == "viewEventFromOrgPageRecPost" {
//            let vc = segue.destination as! Event
//            vc.event = self.eventClicked
//            vc.userProfile = self.userProfile
//        }
//        //if they click on the ad, then take them to the link of where that add is and icrement the counter to indicate the ad has been seen.
////        if segue.identifier == "viewAdFromOrgPageRecPost" {
////
////        }
//    }
}
