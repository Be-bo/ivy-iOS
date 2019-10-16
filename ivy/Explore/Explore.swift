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
    private let SF_BATCH_SIZE = 10                                              //size of a single query fetch for our pagination system
    private let SF_BATCH_TOLERANCE = 4                                          //how far the user has to be from the end of the list to start loading a new batch
    private var loadedAllProfiles = false
    private var profileLoadInProgress = false
    private var sfDefaultQuery:Firebase.Query?=nil
    private var lastRetrievedProfile:QueryDocumentSnapshot?=nil
    
    private var dataLoaded = false
    private var appMinimized = false
    
    
    @IBOutlet weak var featuredLoadingWheel: LoadingWheel!
    @IBOutlet weak var featuredHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var featuredEventImage: UIImageView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var recommendedFriendCollecView: UICollectionView!
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    
    
    let eventCollectionIdentifier = "EventCollectionViewCell"
    let profileCollectionIdentifier = "profileCollectionViewCell"
    var searchLauncher = SearchLauncher()
    var searchVisible = false
    var timer = Timer()
    var userListsListenerRegistration: ListenerRegistration? = nil
    
    
    
    
    
    
    
    
    
    
    // MARK: Search Functions
    
    @IBAction func searchEdited(_ sender: Any) {
        if(!searchVisible){
            searchCancelButton.isHidden = false
            searchVisible = true
            searchLauncher.triggerPanel(searchBar: searchBar, navBarHeight: self.navigationController?.navigationBar.frame.size.height ?? 100, thisUser: thisUserProfile, rulingVC: self)
        }
    }
    @IBAction func cancelSearchClicked(_ sender: Any) {
        cancelSearch()
    }
    
    func cancelSearch(){
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
    
    override func viewDidLoad() { //called on ViewController creation
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
        if let type = searchResult["search_type"] as? String{
            switch(type){
            case "user":
                cancelSearch()
                self.suggestedProfileClicked = searchResult
                self.performSegue(withIdentifier: "viewFullProfileSegue", sender: self)
                break
            case "event":
                cancelSearch()
                self.eventClicked = searchResult
                self.performSegue(withIdentifier: "exploreToEventPageSegue", sender: self)
                break
            case "organization":
                cancelSearch()
                self.organizationClicked = searchResult
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
    
//    override func viewDidDisappear(_ animated: Bool) {
//        print("EXPLORE DISAPPEARED")
//        if userListsRegistration != nil{
//            userListsRegistration?.remove()
//        }
//    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Setup Functions
    
    @objc private func refresh(){ //method for reloading data that doesn't update automatically (events), called when the user maximizes the app
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.setFeaturedEvent()
            self.loadEvents()
        }
    }
    
    private func adjustScrollViewHeight(){
        let bottomMostPoint = self.recommendedFriendCollecView.frame.origin.y + self.recommendedFriendCollecView.frame.height
        self.scrollViewContentHeight.constant = bottomMostPoint + 32
    }
    
    private func setUp(){ //initial setup method when the ViewController's first created
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil) //add a listener to the app to call refresh inside of this VC when the app goes from background to foreground (is maximized)
                
        eventsCollectionView.delegate = self //events setup
        eventsCollectionView.dataSource = self
        eventsCollectionView.register(UINib(nibName:eventCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: eventCollectionIdentifier)
        
        recommendedFriendCollecView.delegate = self //suggested friends setup
        recommendedFriendCollecView.dataSource = self
        recommendedFriendCollecView.register(UINib(nibName:profileCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: profileCollectionIdentifier)
        
        eventsCollectionView.tag = 0
        recommendedFriendCollecView.tag = 1
        
        startLoadingData() //*option one, if the profile's updated before the UI setup is finished we can start loading Firestore data
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo_small"))
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
        if(!dataLoaded){ //*option two, the UI's initiated but the data hasn't been loaded yet (because the user profile was nil during the UI setup)
            startLoadingData()
        }
    }
    
    
    
    
    
    
    
    // MARK: Collection View Methods
    
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
            checkForNewSFBatch() //also check if a new batch of suggested friends needs to be loaded atm
            return cellSize
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
        if self.allSuggestedFriends.count >= 0 {
            if collectionView.tag == self.eventsCollectionView.tag {
                self.eventClicked = self.allEvents[indexPath.item]   //use currentley clicked index to get conversation id
                self.performSegue(withIdentifier: "exploreToEventPageSegue" , sender: self) //pass data over to
            }else{
                self.suggestedProfileClicked = self.allSuggestedFriends[indexPath.item]   //use currentley clicked index to get conversation id
                self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.eventsCollectionView{
            let eventCard = collectionView.dequeueReusableCell(withReuseIdentifier: eventCollectionIdentifier, for: indexPath) as! EventCollectionViewCell
            eventCard.image.isHidden = true
            eventCard.loadingWheel.isHidden = false
            eventCard.loadingWheel.startAnimating()
        }else{
            let profileCard = collectionView.dequeueReusableCell(withReuseIdentifier: profileCollectionIdentifier, for: indexPath) as! profileCollectionViewCell
            profileCard.imageView.isHidden = true
            profileCard.loadingWheel.isHidden = false
            profileCard.loadingWheel.startAnimating()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { //check when the user scrolls to see if need to obtain the next batch of data
        checkForNewSFBatch()
    }
    
    func checkForNewSFBatch(){ //check is we should load a new batch of suggested friends
        let visibleCells = recommendedFriendCollecView.visibleCells
        if(visibleCells.count > 0){
            if let lastCell = visibleCells[visibleCells.count - 1] as? profileCollectionViewCell {
                if let lastCellId = lastCell.profile["id"] as? String{
                    if let index = allSuggestedFriends.firstIndex(where: {($0["id"] as? String) == lastCellId}){
                        if(!profileLoadInProgress && index >= (allSuggestedFriends.count - SF_BATCH_TOLERANCE)){ //check for pagination (we have to be at the end of the current batch of data within the set tolerance and there can be no load in progress)
                            if(lastRetrievedProfile != nil && !loadedAllProfiles){ //also make sure we haven't loaded everyone we could yet and that last retrieved profile has been assigned
                                let continuationQuery = sfDefaultQuery?.start(afterDocument: lastRetrievedProfile!) //continue grabbing profiles from where we left off in the database
                                self.getSuggestedFriends(query: continuationQuery!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Methods
    
    func startLoadingData(){
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.setFeaturedEvent()
            self.loadEvents()
            self.startListeningToUserLists()
            self.dataLoaded = true
        }
    }
    
    func setFeaturedEvent() {
        self.featuredLoadingWheel.isHidden = false
        let featuredImgWidth = CGFloat(featuredEventImage.frame.width)
        featuredHeightConstraint.constant = featuredImgWidth
        
        //extract the university this person is a part of
        if let userDomain = self.thisUserProfile["uni_domain"] as? String{
            self.baseDatabaseReference.collection("universities").document(userDomain).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let uni = document.data(), let featuredId = uni["featured_id"] as? String, featuredId != ""{  //extract that featured event from that university
                        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").document(featuredId).getDocument { (document, error) in
                            if let document = document, document.exists {
                                self.featuredEventClicked = document.data()!
                                let isFeatured = self.featuredEventClicked["is_featured"] as! Bool
                                let isActive = self.featuredEventClicked["is_active"] as! Bool
                                let endTime = self.featuredEventClicked["end_time"] as! CLong
                                if(isFeatured && isActive && endTime > Int(Date().timeIntervalSince1970)){  //make sure its active and actually a featured event, check exp time
                                    self.featuredEventImage.isHidden = false
                                    
                                    if let clickFeaturedImageString = self.featuredEventClicked["image"] as? String {
                                        //TODO: set text of featured image to be visible here if we choose to have the text hidden @ other times
                                        self.baseStorageReference.reference().child(clickFeaturedImageString).getData(maxSize: 1 * 1024 * 1024) { data, error in  //download image
                                            if let error = error {
                                                print("error", error)
                                            } else {
                                                self.featuredEventImage.image  = UIImage(data: data!)   //populate cell with downloaded image
                                                self.featuredLoadingWheel.isHidden = true
                                                let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.onClickFeatured))
                                                self.featuredEventImage.isUserInteractionEnabled = true
                                                self.featuredEventImage.addGestureRecognizer(singleTap)
                                            }
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
        

    }
    
    func loadEvents(){ //load all the events except for the featured event
        self.allEvents = [Dictionary<String, Any>]()
        
        if let userDomain = self.thisUserProfile["uni_domain"] as? String{
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").whereField("end_time", isGreaterThan: Date().millisecondsSince1970).order(by: "end_time", descending: false).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if (!document.data().isEmpty){
                            var event = document.data()
                            let isFeatured = event["is_featured"] as! Bool
                            let isActive = event["is_active"] as! Bool
                            let endTime = event["end_time"] as! Int64
                            if (!isFeatured && isActive && endTime > Int64(Date().millisecondsSince1970)){
                                var eventAlreadyAdded = false
                                if(!self.allEvents.contains(where: { (currentEvent) -> Bool in //if not true that an event with this id already exists in our events
                                    if let aboutToAddId = event["id"] as? String, let testingAgainstId = currentEvent["id"] as? String, aboutToAddId == testingAgainstId{
                                        return true
                                    }else{
                                        return false
                                    }
                                })){
                                    self.allEvents.append(event)
                                }
                            }
                        }
                    }
                    self.eventsCollectionView.reloadData()
                }
            }
        }
    }
    
    func startListeningToUserLists(){
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String{
            self.sfDefaultQuery = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").order(by: "registration_millis", descending: true).limit(to: SF_BATCH_SIZE) //assign the default query for loading suggested profiles
            
            //make sure the user is actually signed in and authenticated first to prevent the signout error
            Auth.auth().addStateDidChangeListener { (auth, user) in
                       if user != nil {
                        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisId = self.thisUserProfile["id"] as? String{
                            self.userListsListenerRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisId).collection("userlists").addSnapshotListener { (querSnap, err) in
                            if err != nil {
                                print("Error loading user's lists in Explore: ", err)
                            }else{
                                print("userlists changes registered")
                                querSnap?.documentChanges.forEach({ (docChan) in
                                    switch(docChan.document.documentID){
                                    case "requests": self.requests = docChan.document.data()
                                        break
                                    case "block_list": self.blockList = docChan.document.data()
                                        break
                                    case "blocked_by": self.blockedBy = docChan.document.data()
                                        break
                                    case "friends": self.friends = docChan.document.data()
                                        break
                                    default:
                                        break
                                    }
                                })
                                self.lastRetrievedProfile = nil //restart the pagination (we want to load suggested friends all over again when there's a change in user lists)
                                self.allSuggestedFriends = [Dictionary<String, Any>]()
                                self.getSuggestedFriends(query: self.sfDefaultQuery!)
                            }
                        }
                    }
                } else { // user is not signed in so don't attach any listeners and dont load any data
                        self.userListsListenerRegistration?.remove()
                }
            }
        }
    }
    
    
    
    
    func getSuggestedFriends(query: Firebase.Query) { //load a new batch of user profiles based on the query in the argument 
        profileLoadInProgress = true
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let querSnapDocs = querySnapshot?.documents, !querSnapDocs.isEmpty{
                    for i in 0..<querSnapDocs.count { //go through all the fetched profiles
                            let document = querSnapDocs[i]
                            if let docData = document.data() as? Dictionary<String, Any>, !docData.isEmpty{
                                print("AZfetching: ",docData["first_name"] as! String)
                                if let thisUserId = self.thisUserProfile["id"] as? String, let toAddId = docData["id"] as? String, let profHidden = docData["profile_hidden"] as? Bool, !profHidden{
                                    if (thisUserId != toAddId && !self.blockedBy.contains(where: { $0.key == toAddId}) && !self.blockList.contains(where: { $0.key == toAddId}) && !self.friends.contains(where: { $0.key == toAddId}) && !self.requests.contains(where: { $0.key == toAddId}) ){
                                        self.allSuggestedFriends.append(docData)
                                    }
                                }
                            }
                            if(i >= querSnapDocs.count - 1){
                                self.lastRetrievedProfile = document
                                self.adjustScrollViewHeight()
                            }
                        }
                    
                        self.recommendedFriendCollecView.reloadData()
                }else{
                    print("loadedAllProfiles")
                    self.loadedAllProfiles = true
                }
                self.profileLoadInProgress = false
            }
        }
    }
}



protocol SearchCellDelegator { //a delgator that allows SearchCell.swift trigger segues in this view controller through the SearchLauncher (when they click on the given search result they'll be taken to the appropriate view controller)
    func callSegueFromCell(searchResult: Dictionary<String, Any>)
}

