//
//  Explore.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class Explore: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: Variables and Constant

    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage()                         //reference to storage
    //for events
    private var thisUserProfile = Dictionary<String, Any>()
    private var allEvents = [Dictionary<String, Any>]()                          //array of dictionaries for holding each seperate event
    private var eventClicked = Dictionary<String, Any>()                         //actual event that was clicked
    //suggested friends vars
    private var allSuggestedFriends = [Dictionary<String, Any>]()
    private var requests = Dictionary<String, Any>()
    private var friends = Dictionary<String, Any>()
    private var blockList = Dictionary<String, Any>()
    private var blockedBy = Dictionary<String, Any>()
    private var suggestedProfileClicked = Dictionary<String, Any>()             //holds the other profile that was clicked from the suggested friends collection
    private var featuredEventClicked = Dictionary<String, Any>()                //for featured event
    
    private var data_loaded = false
    
    @IBOutlet weak var featuredEventImage: UIImageView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var recommendedFriendCollecView: UICollectionView!
    
    let eventCollectionIdentifier = "EventCollectionViewCell"
    let profileCollectionIdentifier = "profileCollectionViewCell"
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUp()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        if segue.identifier == "exploreToEventPageSegue" {
            let vc = segue.destination as! Event
            vc.event = self.eventClicked
            //        vc.eventID = self.eventClicked["id"] as! String
            vc.userProfile = self.thisUserProfile
            //        self.baseDatabaseReference.collection("universities").document(self.eventClicked["uni_domain"] as! String).collection("events").document(self.eventClicked["id"] as! String).updateData(["views": FieldValue.arrayUnion([Date().millisecondsSince1970])]) //log a view for the event
        }
        if segue.identifier == "viewFullProfileSegue" {
            let vc = segue.destination as! ViewFullProfileActivity
            vc.isFriend = true
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.suggestedProfileClicked["id"] as? String
        }
    }
    
    @objc func onClickFeatured() { //when they click the featured event, transition them to the page that has all the information about tha that event
        self.eventClicked = self.featuredEventClicked   //use currentley clicked index to get conversation id
        self.performSegue(withIdentifier: "exploreToEventPageSegue" , sender: self) //pass data over to
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Setup Functions
    
    private func setUp(){
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.register(UINib(nibName:eventCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: eventCollectionIdentifier)
        
        recommendedFriendCollecView.delegate = self
        recommendedFriendCollecView.dataSource = self
        recommendedFriendCollecView.register(UINib(nibName:profileCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: profileCollectionIdentifier)
        
        eventsCollectionView.tag = 0
        recommendedFriendCollecView.tag = 1
        
        startLoadingData() //*option one, if the profile's updated before the UI setup is finished we can start loading Firestore data
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
//        // this retarded bs is not working
//        let settingsBtn = SettingsButton()
//        let settingsButton = UIBarButtonItem(customView: settingsBtn)
//        navigationItem.rightBarButtonItem = settingsButton
        
        
        //TODO: tidy this up
        let navigationBarWidth: CGFloat = self.navigationController!.navigationBar.frame.width
        var leftButton = UIButton(frame:CGRect(x: navigationBarWidth / 2.3, y: 0, width: 40, height: 40))
        var background = UIImageView(image: UIImage(named: "settings"))
        background.frame = CGRect(x: navigationBarWidth / 2.3, y: 0, width: 40, height: 40)
        leftButton.addSubview(background)
        self.navigationController!.navigationBar.addSubview(leftButton)
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        self.thisUserProfile = updatedProfile
        if(!data_loaded){ //*option two, the UI's initiated but the data hasn't been loaded yet (because the user profile was nil during the UI setup)
            startLoadingData()
        }
    }
    
    
    
    
    
    
    
    // MARK: Collection View Delegate and Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.eventsCollectionView {
            return self.allEvents.count
        }else{
            return self.allSuggestedFriends.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.eventsCollectionView {
            let eventCard = collectionView.dequeueReusableCell(withReuseIdentifier: eventCollectionIdentifier, for: indexPath) as! EventCollectionViewCell
            eventCard.setUp(event: allEvents[indexPath.item])
            return eventCard
        }else{
            let profileCard = collectionView.dequeueReusableCell(withReuseIdentifier: profileCollectionIdentifier, for: indexPath) as! profileCollectionViewCell
            profileCard.setUpWithProfile(profile: allSuggestedFriends[indexPath.item])
            return profileCard
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.eventsCollectionView {
            let cellSize = CGSize(width: 130, height: self.eventsCollectionView.frame.size.height)
            return cellSize
        }else{
            let cellSize = CGSize(width: 130, height: self.recommendedFriendCollecView.frame.size.height)
            return cellSize
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
        if collectionView.tag == self.eventsCollectionView.tag {
            self.eventClicked = self.allEvents[indexPath.item]   //use currentley clicked index to get conversation id
            self.performSegue(withIdentifier: "exploreToEventPageSegue" , sender: self) //pass data over to
        }else{
            self.suggestedProfileClicked = self.allSuggestedFriends[indexPath.item]   //use currentley clicked index to get conversation id
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
        }
        
    }
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Methods
    
    func startLoadingData(){
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.loadFeaturedEvent()
            self.loadEvents()
            self.getSuggestedFriends()
            self.data_loaded = true
        }
    }
    
    func loadFeaturedEvent() {
        //extract the university this person is a part of
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).getDocument { (document, error) in
            if let document = document, document.exists {
                var uni = document.data()
                let featuredId = uni!["featured_id"] as! String
                if (featuredId != ""){  //extract that featured event from that university
                    self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").document(featuredId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.featuredEventClicked = document.data()!
                            let isFeatured = self.featuredEventClicked["is_featured"] as! Bool
                            let isActive = self.featuredEventClicked["is_active"] as! Bool
                            let endTime = self.featuredEventClicked["end_time"] as! CLong
                            if(isFeatured && isActive && endTime > Int(Date().timeIntervalSince1970)){  //make sure its active and actually a featured event, check exp time
                                self.featuredEventImage.isHidden = false
                                //TODO: set text of featured image to be visible here if we choose to have the text hidden @ other times
                                self.baseStorageReference.reference().child(self.featuredEventClicked["image"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in  //download image
                                    if let error = error {
                                        print("error", error)
                                    } else {
                                        self.featuredEventImage.image  = UIImage(data: data!)   //populate cell with downloaded image
                                        //add on click listener that takes them to the event page when they click on the image
                                        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.onClickFeatured))
                                        self.featuredEventImage.isUserInteractionEnabled = true
                                        self.featuredEventImage.addGestureRecognizer(singleTap)
                                    }
                                }
                            }else{
                                //TODO: set text of featured image to be INVISIBLE here if we choose to have the text hidden @ other times
                                self.featuredEventImage.isHidden = true
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadEvents(){ //load all the events except for the featured event
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").order(by: "time_millis", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if (!document.data().isEmpty){
                        var event = document.data()
                        let isFeatured = event["is_featured"] as! Bool
                        let isActive = event["is_active"] as! Bool
                        let endTime = event["end_time"] as! Int64
                        if (!isFeatured && isActive && endTime > Date().millisecondsSince1970 ){
                            self.allEvents.append(event)
                        }
                    }
                }
                self.eventsCollectionView.reloadData()
            }
        }
    }
    
    //welcome to callback hell. (,,)(-.-)(,,)
    //load all the suggested friends for this particular user so we can then populate the collection view.
    func getSuggestedFriends() {
        
        //getting all the users that this user's already added as friends, requested friendship or are on their block list (or were blocked by the other person), note that any and all of these lists might be empty so we keep grabbing the next one in succession regardless of whether we obtain the current list or not

        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").getDocument { (document, error) in
            if let document = document, document.exists {
                self.requests = document.data()!
            } else {
                print("Document does not exist")
            }
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
                if let document = document, document.exists {
                    self.friends = document.data()!
                } else {
                    print("Document does not exist")
                }
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.blockList = document.data()!
                    } else {
                        print("Document does not exist")
                    }
                    self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("blocked_by").getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.blockedBy = document.data()!

                        } else {
                            print("Document does not exist")
                        }
                        
                        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    if (!document.data().isEmpty){
                                        var profileToAdd = document.data()
                                        if (self.thisUserProfile["id"] as! String != profileToAdd["id"] as! String && !self.blockedBy.contains(where: { $0.key == profileToAdd["id"] as! String}) && !self.blockList.contains(where: { $0.key == profileToAdd["id"] as! String}) && !self.friends.contains(where: { $0.key == profileToAdd["id"] as! String}) && !self.requests.contains(where: { $0.key == profileToAdd["id"] as! String}) ){
                                            let bool = profileToAdd["profile_hidden"] as! Bool
                                            if !(bool == true){
                                                self.allSuggestedFriends.insert(document.data(), at: 0)
                                                self.recommendedFriendCollecView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }   //end of function
}

