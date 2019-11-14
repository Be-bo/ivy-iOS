//
//  Quad.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class Quad: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Variables and Constants
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var allQuadProfiles = [Dictionary<String, Any>]()
    private let cellId = "QuadCard"
    private let baseDatabaseReference = Firestore.firestore()
    private var requests = Dictionary<String, Any>()
    private var friends = Dictionary<String, Any>()
    private var block_list = Dictionary<String, Any>()
    private var blocked_by = Dictionary<String, Any>()
    var keyboardHeight:CGFloat = 0
    private var currentCard:Card? = nil
    
    //PAGINATION
    private let QUAD_BATCH_SIZE = 10    //size of single query fetch
    private let QUAD_BATCH_TOLERANCE = 2  //before loading more profiles
    private var loadedAllProfiles = false
    private var profileLoadInProgress = false
    private var sfDefaultQuery:Firebase.Query?=nil
    private var lastRetrievedProfile:QueryDocumentSnapshot?=nil
    var quadUserListsListenerRegistration: ListenerRegistration? = nil
    private var dataLoaded = false
    private var currentPos = 0           //actual position we are at in the quad collection view
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var quadCollectionView: UICollectionView!
    
    
    
    
    
    
    
    
    
    // MARK: Setup and Override Functions
    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        self.setUpKeyboardListeners()
        setUpNavigationBar()
        setUp()
    }
    
    private func setUp(){ //set up everything we need for the UI
        quadCollectionView.delegate = self
        quadCollectionView.dataSource = self
        quadCollectionView.register(UINib(nibName: "Card", bundle: nil), forCellWithReuseIdentifier: cellId)
//        let sidePadding = (quadCollectionView.frame.size.width - cell width)/2 //side padding for each card is 5% of collection view's width
//        quadCollectionView.contentInset = UIEdgeInsets(top: 0, left: sidePadding, bottom: 0, right: sidePadding)
        
        if(!thisUserProfile.values.isEmpty){
            self.startListeningToQuadLists()
//            loadQuadProfiles()
        }
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
    
    @objc func settingsClicked() { //if settings clicked, segue over to the settings page
        self.performSegue(withIdentifier: "quadToSettings" , sender: self) //pass data over to
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quadToSettings" {
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }
        else if segue.identifier == "viewFullProfileSegue" {
            let vc = segue.destination as! ViewFullProfileActivity
            vc.isFriend = true
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.currentCard?.id
        }
    }
    
    
    //TODO get rid of this stuff when we can have the actions on the back of the card appear
    @objc func showActions() {
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        //ADDING ACTIONS TO THE ACTION SHEET
        actionSheet.addAction(UIAlertAction(title: "View Profile", style: .default, handler: self.onClickViewProfile))
        actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: self.reportUser))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func onClickViewProfile(alert:UIAlertAction!){ //on click view profile take them to that users profile
        //segue to view full profile
         self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self)
        
    }
    
    //TODO: get the id from the card thats clicked
    func reportUser(alert: UIAlertAction!){ //when they click on reporting the USER send them here
        var report = Dictionary<String, Any>()
        
        
        report["reportee"] = self.thisUserProfile["id"] as! String
        report["report_type"] = "user"
        report["target"] = self.currentCard?.id //current card that they're on, id from that card
        report["time"] = Date().millisecondsSince1970
        let reportId = self.baseDatabaseReference.collection("reports").document().documentID   //create unique id for this document
        report["id"] = reportId
        //TODO: change self.card clicked to be the id of that person from the card
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.currentCard?.id ).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if(!querySnapshot!.isEmpty){
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You have already reported this user.", context: self)
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Success", infoText: "The user has been reported.", context: self)
                }
            }
        }
    }

    
//    //when user wants to send hi message to another user from quad from the back of the card.
//    func onClickSendHiMsg(alert:UIAlertAction!){
//
//        //TODO: figure out how to click on text label/button from back of card, and actually send message to user
//        //extract message from text label
//        var sendHiMessage = "Tester message for now"
//
//    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Functions
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){ //a method called from the outside by the MainTabController which listens to changes in this user's profile and pushes them right away
        thisUserProfile = updatedProfile
    }
    
    func startListeningToQuadLists(){ //listener that will keep track of the current profiles avaialble and load them in batch sizes
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String{
            self.sfDefaultQuery = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").order(by: "registration_millis", descending: true).limit(to: QUAD_BATCH_SIZE) //assign the default query for loading suggested profiles
            
            //make sure the user is actually signed in and authenticated first to prevent the signout error
            Auth.auth().addStateDidChangeListener { (auth, user) in
                       if user != nil {
                        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisId = self.thisUserProfile["id"] as? String{
                            self.quadUserListsListenerRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisId).collection("userlists").addSnapshotListener { (querSnap, err) in
                            if err != nil {
                                print("Error loading user's lists in Explore: ", err)
                            }else{
                                print("userlists changes registered")
                                querSnap?.documentChanges.forEach({ (docChan) in
                                    switch(docChan.document.documentID){
                                    case "requests": self.requests = docChan.document.data()
                                        break
                                    case "block_list": self.block_list = docChan.document.data()
                                        break
                                    case "blocked_by": self.blocked_by = docChan.document.data()
                                        break
                                    case "friends": self.friends = docChan.document.data()
                                        break
                                    default:
                                        break
                                    }
                                })
                                self.lastRetrievedProfile = nil //restart the pagination (we want to load suggested friends all over again when there's a change in user lists)
                                self.allQuadProfiles = [Dictionary<String, Any>]()
                                self.obtainNewBatch(query: self.sfDefaultQuery!, insertAtTheBeginning: false, firstLoad: true)
                                //TODO: scroll to the middle
                            }
                        }
                    }
                } else { // user is not signed in so don't attach any listeners and dont load any data
                        self.quadUserListsListenerRegistration?.remove()
                }
            }
        }
    }
    
    func obtainNewBatch(query: Firebase.Query, insertAtTheBeginning: Bool, firstLoad: Bool) { //load the possible friends real time from firestore accounting for the blocked peole
        var newBatch = [Dictionary<String, Any>]()
        let posThatTriggeredLoading = currentPos
        profileLoadInProgress = true
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let querSnapDocs = querySnapshot?.documents, !querSnapDocs.isEmpty{
                    for i in 0..<querSnapDocs.count { //go through all the fetched profiles
                        let document = querSnapDocs[i]
                        if let docData = document.data() as? Dictionary<String, Any>, !docData.isEmpty{
                            if let thisUserId = self.thisUserProfile["id"] as? String, let toAddId = docData["id"] as? String, let profHidden = docData["profile_hidden"] as? Bool, !profHidden{
                                if (thisUserId != toAddId && !self.blocked_by.contains(where: { $0.key == toAddId}) && !self.block_list.contains(where: { $0.key == toAddId}) && !self.friends.contains(where: { $0.key == toAddId}) && !self.requests.contains(where: { $0.key == toAddId}) ){
                                    newBatch.append(docData)
                                }
                            }
                        }
                        if(i >= querSnapDocs.count - 1){
                            self.lastRetrievedProfile = document
                            //TODO: decide if need to adjust scroll view height here or not
                            //self.adjustScrollViewHeight()
                        }
                    }
                    
                    //now add all the items of the new batch depending on which way the user's scrolling
                    if(insertAtTheBeginning){ //insert this person to the beginning of the quad collection view
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.allQuadProfiles.insert(contentsOf: newBatch, at: 0)
                        self.quadCollectionView?.insertItems(at: [indexPath])
                        self.quadCollectionView.scrollToItem(at: IndexPath(item: posThatTriggeredLoading + newBatch.count, section: 0), at: .centeredHorizontally, animated: false)
                    }else{ //insert this person to the end of the quad collection view
                        let indexPath = IndexPath(row: self.allQuadProfiles.count, section: 0)
                        self.allQuadProfiles.append(contentsOf: newBatch)
                        self.quadCollectionView?.insertItems(at: [indexPath])
                    }
                    
                    if(firstLoad){ //if loading for the first time -> have to scroll to the middle of the quad
                        self.quadCollectionView.scrollToItem(at: IndexPath(item: self.allQuadProfiles.count/2, section: 0), at: .centeredHorizontally, animated: false)
                    }
                    
                    //don't reload entire quad to avoid the card's flashing... just add to the end of the quad
                    
                    //                            self.quadCollectionView.insertItems(at: [
                    //                                NSIndexPath(row: self.allQuadProfiles.count-1, section: 0) as IndexPath])
                    //                            self.quadCollectionView.reloadData()
                }else{
                    print("loadedAllProfiles")
                    self.loadedAllProfiles = true
                }
                self.profileLoadInProgress = false
            }
        }
    }
    
        func checkForNewBatch(){ //DOESN'T BELONG HERE! NOT AN OVERRIDE METHOD!
            //I need to check how many profiles have been binded to the collection view,
            
            print("allQuadProfiles.count " , allQuadProfiles.count )
            //if there has been Batch size - batch tolerance profils loaded then I need to load 10 more
            
            //if there is a cell in the index of the batch tolerance then we should load more
    //        if(!profileLoadInProgress && )
            
            
    //        if(!profileLoadInProgress &&  >= (self.allQuadProfiles.count - SF_BATCH_TOLERANCE)){ //new batch tolerance means within how many last items do we want to start loading the next batch (i.e. we have 20 items and tolerance 2 -> the next batch will start loading once the user scrolls to the position 18 or 19)
    //            if(lastRetrievedProfile != null && !loadedAllProfiles){
    //                obtainBatch(default_query.startAfter(last_retrieved_document)); //next batch has to be loaded from where the previous one left off
    //            }
    //        }
            
            
            if(!profileLoadInProgress && self.currentPos  >= (allQuadProfiles.count - QUAD_BATCH_TOLERANCE)){ //check for pagination (we have to be at the end of the current batch of data within the set tolerance and there can be no load in progress)
                if(lastRetrievedProfile != nil && !loadedAllProfiles){ //also make sure we haven't loaded everyone we could yet and that last retrieved profile has been assigned
                    let continuationQuery = sfDefaultQuery?.start(afterDocument: lastRetrievedProfile!) //continue grabbing profiles from where we left off in the database
                    self.obtainNewBatch(query: continuationQuery!, insertAtTheBeginning: false, firstLoad: false)
                }
            }else if(!profileLoadInProgress && self.currentPos <= QUAD_BATCH_TOLERANCE){
                if(lastRetrievedProfile != nil && !loadedAllProfiles){ //also make sure we haven't loaded everyone we could yet and that last retrieved profile has been assigned
                    let continuationQuery = sfDefaultQuery?.start(afterDocument: lastRetrievedProfile!) //continue grabbing profiles from where we left off in the database
                    self.obtainNewBatch(query: continuationQuery!, insertAtTheBeginning: true, firstLoad: false)
                }
            }
            
            
    //        //check is we should load a new batch of suggested friends
    //        let visibleCells = quadCollectionView.visibleCells
    //        if(visibleCells.count > 0){
    //            if let lastCell = visibleCells[visibleCells.count - 1] as? profileCollectionViewCell {
    //                if let lastCellId = lastCell.profile["id"] as? String{
    //                    if let index = allQuadProfiles.firstIndex(where: {($0["id"] as? String) == lastCellId}){
    //                        if(!profileLoadInProgress && index >= (allQuadProfiles.count - SF_BATCH_TOLERANCE)){ //check for pagination (we have to be at the end of the current batch of data within the set tolerance and there can be no load in progress)
    //                            if(lastRetrievedProfile != nil && !loadedAllProfiles){ //also make sure we haven't loaded everyone we could yet and that last retrieved profile has been assigned
    //                                let continuationQuery = sfDefaultQuery?.start(afterDocument: lastRetrievedProfile!) //continue grabbing profiles from where we left off in the database
    //                                self.getQuadFriends(query: continuationQuery!)
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Individual Card Methods
    
    //TODO: add the actual position for dealing with the infinite scrolling feature
    func setRequest(quadCard:Card, pos: Int){
        //moving text field to the front to make it clickable
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer)
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer.back)
        quadCard.back.sayHiButton.addTarget(self, action: #selector(sayHiButtonClicked), for: .touchUpInside) //set on click listener for send message button
        
        //TODO: find a better solution for this where we can make the items from Card.swift clickable
        //moving sync arrow to front to be clickable
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer)
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer.front)
        quadCard.back.flipButton.addTarget(self, action: #selector(flipButtonClicked), for: .touchUpInside)
        quadCard.front.flipButton.addTarget(self, action: #selector(flipButtonClicked), for: .touchUpInside)
        self.currentCard = quadCard
    
        //attach the card,pos, and orig pos to button to be able to use when clicked
        quadCard.back.sayHiButton.Card = quadCard
        quadCard.back.sayHiButton.pos = pos
    }
    
    //on click of the send hi message on back of card
    @objc func flipButtonClicked(_ sender: subclassedUIButton) {
        self.currentCard!.flip()
    }
    
    //on click of the send hi message on back of card
    @objc func sayHiButtonClicked(_ sender: subclassedUIButton) {
        let card = sender.Card
        let pos = sender.pos
        //check length of input field, default is 0 if they didnt input anything
        if (sender.Card?.back.sayHiMessageTextField.text?.count ?? 0 > 1){
            self.sendRequest(quadCard: card!, pos: pos!)
        }else{
            //TODO: display the error message when message si to short to front end
            print("Your message is to short!")
        }
    }
    
    //TODO: deal with actual position once infinite collection view is added
    func sendRequest(quadCard:Card, pos: Int){
        var conversationReference: DocumentReference
        var current = allQuadProfiles[pos]
        conversationReference = self.baseDatabaseReference.collection("conversations").document()
        var participants = [String]()
        var participantNames = [String]()
        participants.append(self.thisUserProfile["id"] as! String)
        participants.append(current["id"] as! String)
        participantNames.append(self.thisUserProfile["first_name"] as! String)
        participantNames.append(current["first_name"] as! String)
        var msgCounts = [CLong]()
        msgCounts.append(0)
        msgCounts.append(0)
        let mutedBy = [String]()
        
        
        //adding to request lists of user, where true is who sent, false is who recieved
        var temp = Dictionary<String, Any>()
        temp[current["id"] as! String] = true
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").setData(temp, merge: true)
        
        temp = Dictionary<String, Any>()//reset
        temp[self.thisUserProfile["id"] as! String] = false
        self.baseDatabaseReference.collection("universities").document(current["uni_domain"] as! String).collection("userprofiles").document(current["id"] as! String).collection("userlists").document("requests").setData(temp, merge: true)
        
        
        //create new conversation object
        var newConversation = Dictionary<String, Any>()
        newConversation["id"] = conversationReference.documentID
        newConversation["name"] = String(self.thisUserProfile["first_name"] as! String)+", "+String(current["first_name"] as! String)
        newConversation["participants"] = participants
        newConversation["is_request"] = true
        newConversation["last_message"] = quadCard.back.sayHiMessageTextField.text
        newConversation["last_message_author"] = self.thisUserProfile["id"] as! String
        newConversation["creation_time"] =  Date().millisecondsSince1970   //millis
        newConversation["participant_names"] =  participantNames
        newConversation["last_message_counts"] = msgCounts
        newConversation["last_message_millis"] = Date().millisecondsSince1970   //millis
        newConversation["message_count"] = 1
        newConversation["is_base_conversation"] = true
        newConversation["muted_by"] = mutedBy
        //push pbject to db
        self.baseDatabaseReference.collection("conversations").document(conversationReference.documentID).setData(newConversation)
        
        print("new conversation ovject: ", newConversation)
        
        //create new message object
        var requestMessage = Dictionary<String, Any>()
        requestMessage["message_text"] = quadCard.back.sayHiMessageTextField.text
        requestMessage["author_id"] = self.thisUserProfile["id"] as! String
        requestMessage["author_first_name"] = self.thisUserProfile["first_name"] as! String
        requestMessage["author_last_name"] = self.thisUserProfile["last_name"] as! String
        requestMessage["conversation_id"] = conversationReference.documentID
        requestMessage["is_text_only"] = true
        requestMessage["file_reference"] = ""
        requestMessage["id"] = NSUUID().uuidString
        requestMessage["creation_time"] = Date().millisecondsSince1970   //millis
        //push message object to db
        self.baseDatabaseReference.collection("conversations").document(conversationReference.documentID).collection("messages").document(requestMessage["id"] as! String).setData(requestMessage)
        //TODO: check if all this stuff is working once the loading is done correctley.
        //assuming the position is passed in correctley this will remove the user from all the wuad profiles then reload it to no longer show them
        //remove profile from quad
        self.allQuadProfiles.remove(at: pos)
//        quadCard.back.sayHiMessageTextField.text = "" //reset the message text on the back of the card
        quadCard.flip() //flip to eliminate the problem where the quad starts on the back side after removing the previous person you just messaged
        print("pos to remove: ", pos)
        print("user to remove: ", self.allQuadProfiles[pos])
        self.quadCollectionView.reloadData()
        
        //TODO:remove the card from the collection view once a user has sent a request over to that other user
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allQuadProfiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let quadCard = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Card
        quadCard.setUp(user: allQuadProfiles[indexPath.item])
        let pos = indexPath.item
        self.currentPos = pos
        self.setRequest(quadCard: quadCard, pos: pos)
        self.currentCard = quadCard
        return quadCard
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { //infinity behavior (add all current profiles at the beginning or at the start but only once everything from the database is fetched)
        if(allQuadProfiles.count - indexPath.item < 3 && !profileLoadInProgress && loadedAllProfiles){ // within 3 of the end -> insert at the end
            profileLoadInProgress = true
            for i in 0...allQuadProfiles.count-1{
                let newIndexPath = IndexPath(row: self.allQuadProfiles.count, section: 0)
                allQuadProfiles.append(allQuadProfiles[i])
                quadCollectionView?.insertItems(at: [newIndexPath])
            }
            profileLoadInProgress = false
            
        }else if (indexPath.item < 3 && !profileLoadInProgress && loadedAllProfiles){ //within 3 of the beginning -> insert at the end
            profileLoadInProgress = true
            let posThatTriggeredLoading = currentPos
            quadCollectionView.isHidden = true
            for i in 0...allQuadProfiles.count-1{
                let newIndexPath = IndexPath(row: self.allQuadProfiles.count, section: 0)
                allQuadProfiles.append(allQuadProfiles[i])
                quadCollectionView?.insertItems(at: [newIndexPath])
            }
            quadCollectionView.scrollToItem(at: IndexPath(item: posThatTriggeredLoading + allQuadProfiles.count/2, section: 0), at: .centeredHorizontally, animated: false)
            quadCollectionView.isHidden = false
            profileLoadInProgress = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //item size has to adjust based on current collection view dimensions (90% of the its size, the rest is padding - see the setUp() function)
        let cellSize = CGSize(width: self.quadCollectionView.frame.size.width * 0.97, height: self.quadCollectionView.frame.size.height * 0.97)
        return cellSize
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkForNewBatch()
        let collectionViewCenterX = self.quadCollectionView.center.x //get the center of the collection view
        
        if(currentCard?.showingBack ?? false){
            currentCard?.flip()
        }
        
        for cell in self.quadCollectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.quadCollectionView.frame.size.width / 2.0 //get the center of the current cell
            let distance = abs(cellCenterX - collectionViewCenterX) //distance between them
            
            let tolerance : CGFloat = 0.02
            let multiplier : CGFloat = 0.105
            var scale = 1.00 + tolerance - ((distance/collectionViewCenterX)*multiplier) //scale the car based on how far it is from the center (tolerance and the multiplier are both arbitrary)
            if(scale > 1.0){ //don't go beyond 100% size
                scale = 1.0
            }
            cell.transform = CGAffineTransform(scaleX: scale, y: scale) //apply the size change
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { //find the largest visibile cell once the scrolling animation finishes and scroll that one to the center
        var indexOfLargestCell = 0
        var largestWidth: CGFloat = 1
        for cell in self.quadCollectionView.visibleCells{
            if cell.frame.size.width >= largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = self.quadCollectionView.indexPath(for: cell){
                    indexOfLargestCell = indexPath.item
                }
            }
        }
        self.quadCollectionView.scrollToItem(at: IndexPath(item: indexOfLargestCell, section: 0), at: .centeredHorizontally, animated: true)
        
        //TODO: this has a weird bug where if I am scrolling forward and stop it abruptly with one card back, then it doesnt know which card was at the centre of the screen so the flipping doesnt work.
        //TODO: decide if this is best practise or not.
        //the card that the scroll view lands on is the same card the user is seeing, thus this is the card theyll be clicking, save it
        if let cClicked = self.quadCollectionView.cellForItem(at: IndexPath(item: indexOfLargestCell, section: 0)) as? Card{
            self.currentCard = cClicked
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Keyboard Functions

    private func setUpKeyboardListeners(){ //setup listeners for if they click on actions to show the keyboard, and when they click on button, to hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let kbHeight = keyboardRectangle.height
        let innerHeight = CGFloat(view.safeAreaLayoutGuide.layoutFrame.size.height) //is 0 for rectangular screens but adds extra screen real estate on "notch" design
        let outerHeight = CGFloat(UIScreen.main.bounds.height)
        let chinForehead = (outerHeight - innerHeight)/2
        self.keyboardHeight = kbHeight + 20 - chinForehead //have to take the safe area around the notch and the chin into account - for iPhone X, XR, XS, XS Max and above
        UIView.animate(withDuration: 0.5){
            self.currentCard?.back.sayHiHeightConstraint.constant = self.keyboardHeight
            self.currentCard?.back.sayHiMessageTextField.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5){
            self.currentCard?.back.sayHiHeightConstraint.constant = 40
            self.currentCard?.back.sayHiMessageTextField.layoutIfNeeded()
        }
    }
    
    
    
    
    
}

//extend UIButton to be able to add the card as a parameter to the button for adding on click target
class subclassedUIButton: UIButton {
    var Card: Card?
    var pos: Int?
    var origPos: Int?
}
