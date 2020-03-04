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
    
    private let QUAD_BATCH_SIZE = 20    //size of single query fetch
    private let QUAD_BATCH_TOLERANCE = 5  //before loading more profiles
    private let MAX_SIZE = 10000
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var userToSendRequestTo = Dictionary<String, Any>()
    private var allQuadProfiles = [Dictionary<String, Any>]()
    private var seenSet = Set<String>()
    private var requests = Dictionary<String, Any>()
    private var friends = Dictionary<String, Any>()
    private var block_list = Dictionary<String, Any>()
    private var blocked_by = Dictionary<String, Any>()
    
    var keyboardHeight:CGFloat = 0
    private var currentCard:Card? = nil
    
    private let cellId = "QuadCard"
    private let baseDatabaseReference = Firestore.firestore()
    private var quadDefaultQuery:Firebase.Query?=nil
    private var lastRetrievedProfile:QueryDocumentSnapshot?=nil
    var quadUserListsListenerRegistration: ListenerRegistration? = nil
    
    private var loadedAllProfiles = false
    private var profileLoadInProgress = false
    private var dataLoaded = false
    private var firstLoad = true
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var quadCollectionView: UICollectionView!
    @IBOutlet weak var emptyQuadLabel: GreenBoldTitleLabel!
    
    
    
    let sender = PushNotificationSender()

    
    
    
    
    
    
    // MARK: Setup and Override Functions
    
    override func viewDidLoad() {
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
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
        if(!thisUserProfile.values.isEmpty){
            self.startListeningToQuadLists()
        }
    }
    

    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo_small"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView

        //u of c logo in the top left gotta be a button just dont add target
        let uOfCImgView = UIButton(type: .custom)
        uOfCImgView.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        uOfCImgView.setImage(UIImage(named:"top_bar_uOfC_Logo"), for: .normal)


        let settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        settingsButton.setImage(UIImage(named:"settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsClicked), for: .touchUpInside)

        let settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = settingsButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true


        uOfCImgView.adjustsImageWhenHighlighted = false //keep color when button is diabled
        uOfCImgView.isEnabled = false //make u of c button unclickable


        let uOfCButtonItem = UIBarButtonItem(customView: uOfCImgView)
        let curruOfCWidth = uOfCButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        curruOfCWidth?.isActive = true
        let curruOfCHeight = uOfCButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        curruOfCHeight?.isActive = true

        //Share Button Next To Settings
        let shareButton = UIButton(type: .custom)
        shareButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        shareButton.setImage(UIImage(named:"share"), for: .normal)
        shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
        let shareButtonItem = UIBarButtonItem(customView: shareButton)
        let currShareWidth = shareButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currShareWidth?.isActive = true
        let currShareHeight = shareButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currShareHeight?.isActive = true


        self.navigationItem.leftBarButtonItem = uOfCButtonItem
        self.navigationItem.rightBarButtonItems = [settingsButtonItem, shareButtonItem]
       }
    
    @objc func settingsClicked() { //if settings clicked, segue over to the settings page
        self.performSegue(withIdentifier: "quadToSettings" , sender: self) //pass data over to
    }
    
    @objc func shareTapped(){ //TODO: potentially move this to the PublicStaticMethodsAndData
        let activityController = UIActivityViewController(activityItems: ["Hi, thought you'd like ivy! Check it out here: https://apps.apple.com/ca/app/ivy/id1479966843."], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quadToSettings" {
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }
        else if segue.identifier == "quadToUserGallery" {
            let vc = segue.destination as! UserGallery
            
            if let otherID = self.currentCard?.id as? String,  let otherDomain = self.thisUserProfile["uni_domain"] as? String{
                vc.thisUniDomain = otherDomain
                vc.otherUserId = otherID
                vc.previousQuadVC = self
            }
            
        }
    }
    
    
    //TODO get rid of this stuff when we can have the actions on the back of the card appear
    @objc func showActions() {
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        //ADDING ACTIONS TO THE ACTION SHEET
//        actionSheet.addAction(UIAlertAction(title: "View Profile", style: .default, handler: self.onClickViewProfile))
        actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: self.reportUser))
        actionSheet.addAction(UIAlertAction(title: "Block", style: .default, handler: self.blockUser))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func onClickViewProfile(alert:UIAlertAction!){ //on click view profile take them to that users profile
        //segue to view full profile
         self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self)
        
    }
    
    
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
    
    

    func blockUser(alert: UIAlertAction!){ //when the user clicks on block user send it here to actually block them
        
        if let userIDToBlock = self.currentCard?.id as? String, let cc = currentCard as? Card{
            
            var toMerge = Dictionary<String,Any>() //update this users block list
            toMerge[String(userIDToBlock)] = Date().timeIntervalSince1970
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").setData(toMerge, merge: true)
            
            toMerge = Dictionary<String,Any>() //update other persons block list
            toMerge[String(self.thisUserProfile["id"] as! String)] = Date().timeIntervalSince1970
            
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(userIDToBlock).collection("userlists").document("blocked_by").setData(toMerge, merge: true, completion: { (error) in
                if error != nil {
                    print("error while uplaoding other persons block list")
                }
                self.quadCollectionView.scrollToItem(at: IndexPath(item: cc.assignedPosition + 1, section: 0), at: .centeredHorizontally, animated: false)
                self.quadCollectionView.scrollToItem(at: IndexPath(item: cc.assignedPosition, section: 0), at: .centeredHorizontally, animated: true)
                self.allQuadProfiles.remove(at: cc.assignedPosition)
                self.quadCollectionView.reloadData()
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Functions
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){ //a method called from the outside by the MainTabController which listens to changes in this user's profile and pushes them right away
        thisUserProfile = updatedProfile
    }
    
    func startListeningToQuadLists(){ //listener that will keep track of the current profiles avaialble and load them in batch sizes
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String{
            self.quadDefaultQuery = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").order(by: "registration_millis", descending: true).limit(to: QUAD_BATCH_SIZE) //assign the default query for loading suggested profiles
            
            //make sure the user is actually signed in and authenticated first to prevent the signout error
            Auth.auth().addStateDidChangeListener { (auth, user) in
                       if user != nil {
                        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisId = self.thisUserProfile["id"] as? String{
                            self.quadUserListsListenerRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisId).collection("userlists").addSnapshotListener { (querSnap, err) in
                            if err != nil {
                                print("Error loading user's lists in Explore: ", err)
                            }else{
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
                                if(self.firstLoad){
                                    self.lastRetrievedProfile = nil //restart the pagination (we want to load suggested friends all over again when there's a change in user lists)
                                    self.allQuadProfiles = [Dictionary<String, Any>]()
                                    self.obtainNewBatch(query: self.quadDefaultQuery!, firstLoad: self.firstLoad)
                                }
                            }
                        }
                    }
                } else { // user is not signed in so don't attach any listeners and dont load any data
                        self.quadUserListsListenerRegistration?.remove()
                }
            }
        }
    }
    
    func obtainNewBatch(query: Firebase.Query, firstLoad: Bool) { //load the possible friends real time from firestore accounting for the blocked peole
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
                                    self.allQuadProfiles.append(docData)
                                }
                            }
                        }
                        if(i >= querSnapDocs.count - 1){self.lastRetrievedProfile = document}
                        
                    }
                    if(firstLoad){
                        let ip = IndexPath(item: 0, section: 0)
                        self.quadCollectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
                        self.quadCollectionView.reloadData()
                        self.firstLoad = false
                    }
//                    self.quadCollectionView.reloadData()
                }else{
                    self.loadedAllProfiles = true
                    self.checkForEmptyQuad()
                }
                self.profileLoadInProgress = false
                if (self.lastRetrievedProfile != nil){ //if a batch is empty, we need to make sure we keep fetching more profiles from the database
                    let continuationQuery = self.quadDefaultQuery?.start(afterDocument: self.lastRetrievedProfile!)
                    self.obtainNewBatch(query: continuationQuery!, firstLoad: false)
                }
            }
        }
    }
    
    func checkForEmptyQuad(){
        if(allQuadProfiles.count < 1){
            emptyQuadLabel.isHidden = false
            quadCollectionView.isHidden = true
            self.view.bringSubviewToFront(emptyQuadLabel)
        }else{
            emptyQuadLabel.isHidden = true
            quadCollectionView.isHidden = false
        }
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
        
        //add listeners more the gallery and more option buttons
        quadCard.front.galleryButton.addTarget(self, action: #selector(self.galleryButtonClick), for: .touchUpInside)
        quadCard.front.moreButton.addTarget(self, action: #selector(self.moreButtonClick), for: .touchUpInside)

        
        self.currentCard = quadCard
    
        //attach the card,pos, and orig pos to button to be able to use when clicked
        quadCard.back.sayHiButton.Card = quadCard
        quadCard.back.sayHiButton.pos = pos
    }
    
    //on click of the send hi message on back of card
    @objc func flipButtonClicked(_ sender: subclassedUIButton) {
        self.currentCard?.flip()
    }
    
    //on click of the send hi message on back of card
    @objc func sayHiButtonClicked(_ sender: subclassedUIButton) {
        let card = sender.Card
        let pos = sender.pos
        //check length of input field, default is 0 if they didnt input anything
        if (sender.Card?.back.sayHiMessageTextField.text?.count ?? 0 > 1){
            if !requests.contains(where: {$0.key == card?.id}){
                if(!blocked_by.contains(where: {$0.key == card?.id})){
                    if(!friends.contains(where: {$0.key == card?.id})){
                        self.sendRequest(quadCard: card!, pos: pos!)
                    }else{
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You're already friends with this person.", context: self)
                    }
                }else{
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You've been blocked by this user.", context: self)
                }
            }else{
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "This user has already sent you a request, check you messages.", context: self)
            }
        }else{
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "Your message is too short, it has to be at least length 2.", context: self)
        }
    }
    
    @objc func galleryButtonClick() {
        self.performSegue(withIdentifier: "quadToUserGallery" , sender: self)
    }
    
    
    //when more clicked prompt them with the action sheet to choose block and report
    @objc func moreButtonClick() {
        showActions()
    }

    
    //TODO: deal with actual position once infinite collection view is added
    func sendRequest(quadCard:Card, pos: Int){
        var conversationReference: DocumentReference
        var current = allQuadProfiles[pos]
        userToSendRequestTo = current   //so I can use it below in send notification
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
        self.baseDatabaseReference.collection("conversations").document(conversationReference.documentID).collection("messages").document(requestMessage["id"] as! String).setData(requestMessage, completion: { (e) in
        if(e != nil){
            print("Error while sending request message: ",e)
        }else{
            self.sendNotification(message:requestMessage)
            self.currentCard?.assignedPosition = -1

            //assuming the position is passed in correctley this will remove the user from all the wuad profiles then reload it to no longer show them
            //remove profile from quad
            self.quadCollectionView.scrollToItem(at: IndexPath(item: pos+1, section: 0), at: .centeredHorizontally, animated: false)
            self.quadCollectionView.scrollToItem(at: IndexPath(item: pos, section: 0), at: .centeredHorizontally, animated: true)
            self.allQuadProfiles.remove(at: pos)
            quadCard.back.sayHiMessageTextField.text = "" //reset the message text on the back of the card

            self.quadCollectionView.reloadData()

            }
        })
    }
    
    
    
    
    
    
    
    //MARK: Request Notification
    private func sendNotification(message:Dictionary<String,Any>) {
        //if ifs a base conversation vs if its not a base conversation
        if let authorFirstName = message["author_first_name"] as? String, let authorLastName = message["author_last_name"] as? String, let messageText = message["message_text"] as? String, let uniDomain = thisUserProfile["uni_domain"] as? String, let conversationID = message["conversation_id"] as? String, let otherId = userToSendRequestTo["id"] as? String {
                self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(otherId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let user = document.data()
                        //user will exist hhere since document data has to  exist here
                        if let usersMessagingToken = user!["messaging_token"] as? String {
                            //actually notify the user of that device
                            self.sender.sendPushNotification(to: usersMessagingToken, title: authorFirstName + " " + authorLastName, body: messageText, conversationID: conversationID)
                            //else title is just name of author for base conversation
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    
    
    
    
    
    
    
    
    
    // MARK: Collection View Methods
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MAX_SIZE
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let quadCard = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Card
        //deque resuses cells so we wanna clear the old image in there so it doesn't show other prfiles
        quadCard.front.img.image = nil
        quadCard.front.degreeIcon.image = nil
        quadCard.front.name.text = "Name"
//        quadCard.prepareForReuse()
        
        
//        if(firstLoad && indexPath.item == 0){
//            self.quadCollectionView.scrollToItem(at: IndexPath(item: 5000, section: 0), at: .centeredHorizontally, animated: false)
//            firstLoad = false
//        }
        

        
        if(allQuadProfiles.count > 0){
            quadCard.startLoading()
            var actualPos = indexPath.item % allQuadProfiles.count
            var currentProfile = allQuadProfiles[actualPos]
            if var currentId = currentProfile["id"] as? String{
                
                if(quadCard.assignedPosition != -1 && quadCard.showingBack){
                    actualPos = quadCard.assignedPosition
                }else{
                    quadCard.assignedPosition = actualPos
                }
                quadCard.setUp(user: currentProfile)
                currentCard = quadCard
                setRequest(quadCard: quadCard, pos: actualPos)
                
                if(!profileLoadInProgress && actualPos >= (allQuadProfiles.count - QUAD_BATCH_TOLERANCE)){
                    if(lastRetrievedProfile != nil && !loadedAllProfiles){
                        let continuationQuery = quadDefaultQuery?.start(afterDocument: lastRetrievedProfile!) //continue grabbing profiles from where we left off in the database
                        obtainNewBatch(query: continuationQuery!, firstLoad: false)
                    }
                }
            }
        }
        return quadCard
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //item size has to adjust based on current collection view dimensions (90% of the its size, the rest is padding - see the setUp() function)
        let cellSize = CGSize(width: self.quadCollectionView.frame.size.width * 0.97, height: self.quadCollectionView.frame.size.height * 0.97)
        return cellSize
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewCenterX = self.quadCollectionView.center.x //get the center of the collection view
        
        if(currentCard?.showingBack ?? false){
            currentCard?.flip()
        }
        
        
        
        for cell in self.quadCollectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.quadCollectionView.frame.size.width / 2.0 //get the center of the current cell
            let distance = abs(cellCenterX - collectionViewCenterX) //distance between them
            
            let tolerance : CGFloat = 0.02
            let multiplier : CGFloat = 0.205
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
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
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
        
        self.currentCard = self.quadCollectionView.cellForItem(at: IndexPath(item: indexOfLargestCell, section: 0)) as! Card
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


