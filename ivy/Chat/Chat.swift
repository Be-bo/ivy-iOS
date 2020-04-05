//
//  Chat.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

class Chat: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: Variables and Constants
    
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    var activeChats: [Dictionary<String, Any>] = []
    var conversationID = ""
    var userAuthFirstName = ""  //first name of the authenticated user
    var userProfilePic = ""
    var uniDomain = ""
    var thisUserId = ""
    var setMessageNotif:Bool = false                                //whether to display message notification dot or not
    private var thisUserProfile = Dictionary<String, Any>()
    private var requestCount = Dictionary<String, Any>()
    
    private var thisConversation = Dictionary<String, Any>()        //the conversation they actually click on when accepting/rejecting
    private var thisCell: ConversationCell? = nil
    private var chatsRegistration:ListenerRegistration? = nil
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noConvLabel: MediumGreenLabel!
    @IBOutlet weak var loadingWheel: LoadingWheel!
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(PublicStaticMethodsAndData.checkProfileIntegrity(profileToCheck: thisUserProfile)){
            setUp()
            setUpNavigationBar()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.isHidden = true
        loadingWheel.isHidden = false
        loadingWheel.startAnimating()
        detachListeners()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(PublicStaticMethodsAndData.checkProfileIntegrity(profileToCheck: thisUserProfile)){
            startListeningToConversations()
            NotificationCenter.default.addObserver(self, selector: #selector(startListeningToConversations), name: UIApplication.willEnterForegroundNotification, object: nil) //add a listener to the app to call refresh inside of this VC when the app goes from background to foreground (is maximized)
            NotificationCenter.default.addObserver(self, selector: #selector(detachListeners), name: UIApplication.didEnterBackgroundNotification, object: nil) //when the app enters background/is killed remove the user from looking ids and detach the comment listener
        }
    }
    
    private func setUp(){
        self.tableView.isHidden = true
        self.noConvLabel.isHidden = true
        self.noConvLabel.layoutIfNeeded()
        self.loadingWheel.isHidden = false
        self.loadingWheel.startAnimating()
        self.loadingWheel.layoutIfNeeded()
        self.configureTableView()
        
        if let uni = thisUserProfile["uni_domain"] as? String, let thisId = thisUserProfile["id"] as? String{
            self.uniDomain = uni
            self.thisUserId = thisId
        }
    }
    
    @objc private func detachListeners(){
        chatsRegistration?.remove()
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
    
    @objc func settingsClicked() {
        self.performSegue(withIdentifier: "chatToSettings" , sender: self) //pass data over to
    }
    
    @objc func shareTapped(){ //TODO: potentially move this to the PublicStaticMethodsAndData
        let activityController = UIActivityViewController(activityItems: ["Hi, thought you'd like ivy! Check it out here: https://apps.apple.com/ca/app/ivy/id1479966843."], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
        if(segue.identifier == "chatToSettings"){
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }else{
            let vc = segue.destination as! ChatRoom
            vc.conversationID = self.conversationID //set the conversation id of chatRoom.swift to contain the one the user clicked on
            vc.thisUserProfile = self.thisUserProfile   //pass the user profile object
        }
    }
    
    
    
    
    
    
    
    
    // MARK: Data Acquistion Functions
    
    @objc private func startListeningToConversations() {   //get all the conversations where this current user is a participant of, add
        
        self.activeChats = []
        chatsRegistration = baseDatabaseReference.collection("conversations").whereField("participants", arrayContains: self.thisUserId).order(by: "last_message_millis", descending: true).addSnapshotListener(){ (querySnapshot, err) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            
            self.baseDatabaseReference.collection("universities").document(self.uniDomain).collection("userprofiles").document(self.thisUserId).collection("userlists").document("requests").getDocument { (document, error) in
                if let document = document, document.exists {
                    self.requestCount = document.data()!
                } else {
                    //just empty
                }
                
                self.tableView.isHidden = true
                self.loadingWheel.startAnimating()
                
                snapshot.documentChanges.forEach { diff in //FOR EACH individual conversation the user has, when its added
                    if (diff.type == .added) {
                        let newConversation = diff.document.data()
                        var dontAdd = self.activeChats.contains { (conversation) -> Bool in //first check if the convo should be added or not
                            if let currentlyCheckingId = conversation["id"] as? String, let newId = newConversation["id"] as? String, newId == currentlyCheckingId{
                                return true
                            }else{
                                return false
                            }
                        }
                        
                        if(self.activeChats.count < 1 || dontAdd == false){ //if the chats are either empty or the convo hasn't been added yet -> actually add the conversation
                            self.activeChats.append(newConversation)
                            self.tableView.reloadData()
                        }
                    }
                    
                    if (diff.type == .modified) { //FOR EACH!!!!!!!! individual conversation the user has, when its modified, we enter this
                        let modifiedData = diff.document.data()
                        if let modifiedID = modifiedData["id"] as? String, let posModified = self.locateIndexOfConvo(id: modifiedID) as? Int, let originalData = self.activeChats[posModified] as? Dictionary<String, Any>, let modifiedCounts = modifiedData["message_count"] as? Int, let originalCounts = originalData["message_count"] as? Int {
                            if(modifiedCounts != originalCounts){
                                var newOrder: [Dictionary<String, Any>] = self.activeChats
                                //then I wanna replace that entry with the new modifiedData that I recieve upon a new message
                                for index in stride(from: posModified, to: 0, by: -1) {
                                    newOrder.insert(newOrder.remove(at: (index-1) ), at: (index))
                                }
                                newOrder[0] = modifiedData  //replace the 0th entry of the array
                                self.activeChats.removeAll()
                                self.activeChats.append(contentsOf: newOrder)
                                newOrder.removeAll()
                                self.tableView.reloadData() //reload rows and section in table view
                            } else {    //any other type of update, so just update the current conv in its current position
                                self.activeChats[posModified] = modifiedData
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    //if a message was removed we enter this
                    if (diff.type == .removed) {
                        
                        //TODO: remove the actual conversation that was removed from android.
                        //TODO: start here tomorrow find out why its calling modified and removed
                        let removedData = diff.document.data()
                        if let removedID = removedData["id"] as? String{
                            let posRemoved = self.locateIndexOfConvo(id: removedID) //with the conversation ID, I get the index of that conversation in the active chats array
                            self.activeChats.remove(at: posRemoved)
                            self.tableView.reloadData() //reload rows and section in table view
                        }
                    }
                }
                self.checkIfShowtableView()
            }
        }
    }
    
    //check to see whether we should show the tableview or not
    func checkIfShowtableView() {
        //if there is atelast one chat, show the tableview and hide the label for no convo
        if(self.activeChats.count >= 1){
            self.noConvLabel.isHidden = true
            self.tableView.isHidden = false
        }else{
            self.noConvLabel.isHidden = false
            self.tableView.isHidden = true
        }
        self.loadingWheel.stopAnimating()
        self.loadingWheel.isHidden = true
    }
    
    func locateIndexOfConvo (id:String) -> Int { //function used to located the index of the conversation from the activeChats array
        var position = 0
        for (index, chat) in self.activeChats.enumerated(){    //for every chat the user is part of
            if id == chat["id"] as! String{  //if the chat has the same id as the modifiedID passed in
                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
                break
            }
        }
        return position
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Tableview Functions
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.activeChats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when you actually click a conversation from the tableview
        if let convId = self.activeChats[indexPath.row]["id"] as? String{    //use currentley clicked index to get conversation id
            self.conversationID = convId
            self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass the conversationID through and segue
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen/on reload
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        var currentConversation = self.activeChats[indexPath.row]  //conversation object which will be passed to the bold checker
        
        self.checkForGroupAndSetName(cell: cell, currentConversation: currentConversation)
        self.checkForRequest(cell: cell, currentConversation: currentConversation)
        self.setPictureAndLastMessage(cell: cell, currentConversation: currentConversation)
        
        cell.setInfo(thisConversation: currentConversation, thisUserProfile: self.thisUserProfile)  //pass the info to conversationCell.swift
        
        let posInConversation = self.locateThisUser(conversation: currentConversation)
        var thisUsersLastCount: CLong
        
        //BOLDING OF MESSAGE TEXT
        if posInConversation != -1, let lastMsgAuthor = currentConversation["last_message_author"] as? String{
                        
            //if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
            if(lastMsgAuthor == thisUserId){
                cell.lastMessage?.font = UIFont(name:"Cordia New", size: 25.0)
            }else{//if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
                if let lastMsgCounts = currentConversation["last_message_counts"] as? [CLong]{
                    if(lastMsgCounts.count >= 0){    //make sure there is actually something that exists in last_message_count
                        thisUsersLastCount = lastMsgCounts[posInConversation]
                        if let actualMsgCount = currentConversation["message_count"] as? CLong{
                            if(actualMsgCount >= 0 && thisUsersLastCount < actualMsgCount){
                                cell.lastMessage?.font = UIFont(name:"Cordia New Bold", size: 25.0)
                            }else{
                                cell.lastMessage?.font = UIFont(name:"Cordia New", size: 25.0)
                            }
                        }
                    }
                }
            }
        }
        
        
        cell.accept.tag = indexPath.row
        cell.accept.addTarget(self, action: #selector(didClickAccept), for: .touchUpInside)
        
        cell.reject.tag = indexPath.row
        cell.reject.addTarget(self, action: #selector(didClickReject), for: .touchUpInside)
        
        return cell
    }
    
    
    
    
    
    
    @objc func didClickAccept(sender: AnyObject) {
        self.thisConversation = self.activeChats[sender.tag]
        self.thisCell = tableView.cellForRow(at: NSIndexPath(row: sender.tag, section: 0) as IndexPath) as! ConversationCell
        self.acceptRequest()
    }
    
    
    
    
    @objc func didClickReject(sender: AnyObject) {
        self.thisConversation = self.activeChats[sender.tag]
        self.thisCell = tableView.cellForRow(at: NSIndexPath(row: sender.tag, section: 0) as IndexPath) as! ConversationCell
        
        //remove the chat from active chats since we deleted the request
        //        self.activeChats.remove(at: sender.tag)
        //        self.tableView.deleteRows(at: [
        //            NSIndexPath(row: sender.tag, section: 0) as IndexPath], with: .fade)
        //        self.tableView.reloadData()
        
        self.rejectRequest()
    }
    
    
    func rejectRequest() {
        self.thisCell!.hideRequestLayout()
        var requesteeId = getOtherParticipantId(currentConversation: self.thisConversation)
        
        //delete thtat covnersation since if they reject it we get rid of the entire conversation object
        if let thisConvId = self.thisConversation["id"] as? String{
            self.baseDatabaseReference.collection("conversations").document(thisConvId).delete()
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId) //request lists deletion... basically get rid of the requests from both the sender adn reciever
                .collection("userlists").document("requests").updateData([requesteeId: FieldValue.delete()])
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(requesteeId)
                .collection("userlists").document("requests").updateData([thisUserId: FieldValue.delete()])
        }
        
        //TODO: delete the collection messages of the conversation from Firestore probably using a cloud function since the subcollection is still there even if convo gone
        //TODO: delete the conversation row from the RecyclerView
    }
    
    
    
    //actually acccept the request amde to chat and be friends
    func acceptRequest(){
        let docData = [String: Any]()   //used to set the hashmap when there is no blocked_by list that exists for this user
        self.thisCell!.hideRequestLayout()
        var requesteeId = getOtherParticipantId(currentConversation: self.thisConversation)
        
        if let thisConvId = self.thisConversation["id"] as? String{
            self.baseDatabaseReference.collection("conversations").document(thisConvId).updateData(["is_request":false])
            
            //one person friend list
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId).collection("userlists").document("friends").getDocument { (document, error) in
                if let document = document, document.exists {
                    //nothing if doc exists
                } else {
                    self.baseDatabaseReference.collection("universities").document(self.uniDomain).collection("userprofiles").document(self.thisUserId).collection("userlists").document("friends").setData(docData)
                }
                self.baseDatabaseReference.collection("universities").document(self.uniDomain).collection("userprofiles").document(self.thisUserId).collection("userlists").document("friends").updateData([requesteeId: thisConvId])
            }
            
            //others friend list
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").getDocument { (document, error) in
                if let document = document, document.exists {
                    //nothing if dox exists
                } else {
                    self.baseDatabaseReference.collection("universities").document(self.uniDomain).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").setData(docData)
                }
                self.baseDatabaseReference.collection("universities").document(self.uniDomain).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").updateData([self.thisUserId: thisConvId])
            }
            
            //deleting requests since there is no more requst if its been accepted
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId).collection("userlists").document("requests").updateData([requesteeId: FieldValue.delete() ])
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(requesteeId).collection("userlists").document("requests").updateData([thisUserId: FieldValue.delete() ])
            self.checkForGroupAndSetName(cell: self.thisCell!, currentConversation: self.thisConversation)
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Support Functions
    
    func setPictureAndLastMessage(cell: ConversationCell, currentConversation: Dictionary<String,Any>){ //settting the picture and the last message of the current dell that is displayed
        
        var authorProfilePicLoc = ""
        let storageRef = self.baseStorageReference.reference()
        if var lastMessageAuthor = currentConversation["last_message_author"] as? String{ //the author of the last message that was sent
            var lastMessageAuthorPos = 0
            
            //if there is participants then add them to aprticipants variable, else its empty
            var participants = [String]()
            if (currentConversation["participants"] != nil) {
                participants = currentConversation["participants"] as! [String]
            }
            
            //get there names too then if they exist
            var participantNames = [String]()
            if (currentConversation["participant_names"] != nil){
                participantNames = currentConversation["participant_names"] as! [String]
            }
            
            if (!participants.isEmpty){
                if(lastMessageAuthor != ""){
                    for (index, participant) in participants.enumerated(){
                        if(participant == lastMessageAuthor){  //if the participant is same as last message author
                            lastMessageAuthorPos = index  //position of the last message author
                            break
                        }
                    }
                    //setting the last message of that cell to be the name of the last author with the corresponding message that he sent
                    if(!participantNames.isEmpty){
                        //TODO: figure out if we need the same stuff as in the andoird version: i.e. "R.string.conversation_adapter_last_message"
                        if let lastMsg = currentConversation["last_message"] as? String{
                            let lastMessageString = participantNames[lastMessageAuthorPos] +  ": " + String(lastMsg)
                            cell.lastMessage.text = lastMessageString
                        }
                    }
                }
                //if 1-1 chat so use the opposing person your chatting with as the profile pic of the conversation
                if(participants.count == 2){
                    var otherId = self.getOtherParticipantId(currentConversation: currentConversation)
                    if (otherId.isEmpty || otherId == ""){
                        otherId = participants[0]
                    }
                    authorProfilePicLoc = "userimages/" + otherId + "/preview.jpg"
                    let storageImageRef = storageRef.child(authorProfilePicLoc)
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            cell.img.image  = UIImage(data: data!)
                        }
                    }
                }else{  // group chat so use last message author as profile pic
                    authorProfilePicLoc = "userimages/" + lastMessageAuthor + "/preview.jpg"
                    let storageImageRef = storageRef.child(authorProfilePicLoc)
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            cell.img.image  = UIImage(data: data!)
                        }
                    }
                }
            }
        }
    }
    
    func checkForRequest(cell: ConversationCell, currentConversation: Dictionary<String,Any> ){ //check if this cell shuld have the checkmark and x for accepting the message request or denying the message request
        var thisUserRequested = true
        
        //extracting which user requested versus which user did the requesting
        if (currentConversation["is_request"] is Bool){
            let isReq = currentConversation["is_request"] as? Bool
            if (isReq != nil && isReq!){
                let otherUserId = self.getOtherParticipantId(currentConversation: currentConversation)   //extract his id
                if (!self.requestCount.isEmpty && self.requestCount[otherUserId] is Bool && self.requestCount[otherUserId] != nil){
                    thisUserRequested = self.requestCount[otherUserId] as? Bool ?? true
                }
            }
        }
        if (!thisUserRequested){
            let name  = cell.name.text
            cell.name.text = name! + " (Pending)"
            cell.showRequestLayout()
        }else{
            cell.hideRequestLayout()
        }
        
    }
    
    func checkForGroupAndSetName(cell: ConversationCell, currentConversation: Dictionary<String,Any> ){ //check if its a group conversation and if so set the name of that group conversation
        
        var participants = [String]() //if there is participants then add them to aprticipants variable, else its empty
        if (currentConversation["participants"] != nil) {
            participants = currentConversation["participants"] as! [String]
        }
        
        var participantNames = [String]() //get their names too then if they exist
        if (currentConversation["participant_names"] != nil){
            participantNames = currentConversation["participant_names"] as! [String]
            
        }
        
        var isBaseConv = false //cehck if its a 1-1 chat or if its a group chat
        if currentConversation["is_base_conversation"] is Bool{ //if its an isntance of a boolean
            isBaseConv = currentConversation["is_base_conversation"] as! Bool
        }
        
        //null pointer checks
        if (!participants.isEmpty && !participantNames.isEmpty && participantNames.count > 0 && participants.count > 0){
            
            if (participants.count > 2){ //if group convo
                cell.groupSymbol.isHidden = false   //show group symbol
                cell.name.text = currentConversation["name"] as? String //set group name for that cell
            }else if (participants.count == 2 && isBaseConv){ //else 1-1 chat
                cell.groupSymbol.isHidden = true    //not group
                var otherParticipantName = currentConversation["name"] as? String
                
                for (index, participant) in participants.enumerated(){
                    if(thisUserId != participant){  //find other participant pos in array
                        otherParticipantName = participantNames[index]  //using that participants index get this name and set it
                    }
                }
                cell.name.text = otherParticipantName
            }else {
                cell.groupSymbol.isHidden = false
                cell.name.text = currentConversation["name"] as? String
            }
        }
    }
    
    func locateThisUser(conversation: Dictionary<String,Any>) -> Int {
        var position = 0
        if let participants = conversation["participants"] as? [String]{
            if(participants.count > 0) {
                for (index, participant) in participants.enumerated(){    //for every chat the user is part of
                    if(thisUserId == participant){  //if the chat has the same id as the modifiedID passed in
                        position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
                    }
                }
                
            }
        }
        
        return position
    }
    
    func getOtherParticipantId(currentConversation: Dictionary<String,Any>) -> String { //return the other participant of this 1-1 chat
        var participants = [String]() //if there is participants then add them to aprticipants variable, else its empty
        if (currentConversation["participants"] != nil) {
            participants = currentConversation["participants"] as! [String]
        }
        var otherParticipant = ""
        if (!participants.isEmpty){
            for (index, participant) in participants.enumerated(){
                if(self.thisUserProfile["id"] as! String != participant){  //find other participant pos in array
                    otherParticipant = participants[index]  //using that participants index get this name and set it
                    break
                }
            }
        }
        return otherParticipant
    }
}
