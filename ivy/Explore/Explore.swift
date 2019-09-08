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
import InstantSearchClient

class Explore: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SearchCellDelegator {

    //MARK: Variables and Constant

    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage()                         //reference to storage
    //for events
    private var thisUserProfile = Dictionary<String, Any>()
    private var allEvents = [Dictionary<String, Any>]()                          //array of dictionaries for holding each seperate event
    private var eventClicked = Dictionary<String, Any>()                         //actual event that was clicked
    private var organizationClicked = Dictionary<String, Any>()                 //organization clicked during search
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
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!

    
    let eventCollectionIdentifier = "EventCollectionViewCell"
    let profileCollectionIdentifier = "profileCollectionViewCell"
    var searchLauncher = SearchLauncher()
    var searchVisible = false
    var timer = Timer()
    
    
    
    
    
    
    
    
    
    
    // MARK: Search Functions
    
    @IBAction func searchEdited(_ sender: Any) {
        if(!searchVisible){
            searchCancelButton.isHidden = false
            searchVisible = true
            searchLauncher.triggerPanel(searchBar: searchBar, navBarHeight: self.navigationController?.navigationBar.frame.size.height ?? 100, thisUser: thisUserProfile, rulingVC: self)
        }
    }
    @IBAction func cancelSearchClicked(_ sender: Any) {
        if(searchVisible){ //reset all values and hide the pertinent UI elems
            searchCancelButton.isHidden = true
            searchVisible = false
            searchBar.endEditing(true)
            searchBar.text = ""
            searchLauncher.panelDismiss()
            searchLauncher = SearchLauncher()
            timer = Timer()
        }
    }
    
    @IBAction func searchTextChanged(_ sender: Any) {
        if(searchBar.text!.count > 0){
            searchLauncher.progressWheel.isHidden = false
            searchLauncher.noResultsLabel.isHidden = true
            timer.invalidate()
            timer = Timer()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(search), userInfo: nil, repeats: false)
        }else{
            searchLauncher.noResultsLabel.isHidden = false
            searchLauncher.progressWheel.isHidden = true
            searchLauncher.resetSearchCollectionView()
        }
    }
    
    @objc func search(){
        if(searchBar.text!.count > 0){
            runSingleSearch()
        }
    }
    
    func runSingleSearch(){
        let currentString = searchBar.text
        
        baseDatabaseReference.collection("other").document("algolia_update").getDocument { (document, error) in
            if let document = document, document.exists {
                if let algoliaUpdate = document.data(){
                    let client = Client(appID: algoliaUpdate["app_id"] as! String, apiKey: algoliaUpdate["api_key"] as! String)
                    let query = Query(query: currentString)
                    query.hitsPerPage = 10
                    
                    let queries = [
                        IndexQuery(indexName: "search_USERS", query: query),
                        IndexQuery(indexName: "search_ORGANIZATIONS", query: query),
                        IndexQuery(indexName: "search_EVENTS", query: query)]
                    
                    client.multipleQueries(queries, strategy: .stopIfEnoughMatches, completionHandler: { (content, error) -> Void in
                        if error == nil {
                            if let nonNullJsonHit = content{
                                self.searchLauncher.resetSearchCollectionView()
                                self.searchLauncher.search(hitJson: nonNullJsonHit)
                            }
                        }
                    })
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
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
        if segue.identifier == "exploreToSettings" {
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }
        if segue.identifier == "exploreToOrganizationSegue" {
            let vc = segue.destination as! organizationPage
            vc.userProfile = self.thisUserProfile
            vc.organizationId = (self.organizationClicked["id"] as? String)!
        }
    }
    
    func callSegueFromCell(searchResult: Dictionary<String, Any>) { //calling segues through the SearchCellDelegator (i.e. segues triggered from SearchCell.swift = items of SearchLauncher's collection view)
        print("callse")
        if let type = searchResult["search_type"] as? String{
            switch(type){
            case "user":
                self.suggestedProfileClicked = searchResult
                self.performSegue(withIdentifier: "viewFullProfileSegue", sender: self)
                break
            case "event":
                self.eventClicked = searchResult
                self.performSegue(withIdentifier: "exploreToEventPageSegue", sender: self)
                break
            case "organization":
                self.suggestedProfileClicked = searchResult
                self.performSegue(withIdentifier: "exploreToOrganizationSegue", sender: self)
                break
            default:
                break
            }
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
        
        let settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        settingsButton.setImage(UIImage(named:"settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsClicked), for: .touchUpInside)
        
        let settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = settingsButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        self.navigationItem.rightBarButtonItem = settingsButtonItem
    }
    
    @objc func settingsClicked() {
        self.performSegue(withIdentifier: "exploreToSettings" , sender: self) //pass data over to
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

protocol SearchCellDelegator { //a delgator that allows SearchCell.swift trigger segues in this view controller (when they click on the given search result they'll be taken to the appropriate view controller)
    func callSegueFromCell(searchResult: Dictionary<String, Any>)
}

