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
    var conversations: [String: Int] = [:]  //Format: "conversationID":"messageCount"
    var uid = ""    //user id for the authenticated user
    var conversationID = ""
    var userAuthFirstName = ""  //first name of the authenticated user
    var userProfilePic = ""
    var setMessageNotif:Bool = false                                //whether to display message notification dot or not
    private var thisUserProfile = Dictionary<String, Any>()
    private var requestCount = Dictionary<String, Any>()
    
    
    private var thisConversation = Dictionary<String, Any>()        //the conversation they actually click on when accepting/rejecting
    private var thisCell: ConversationCell? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noConvLabel: MediumGreenLabel!
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the tableview and show the label at first
        self.tableView.isHidden = true
        self.noConvLabel.isHidden = false
        self.configureTableView()

        self.userAuthFirstName = thisUserProfile["first_name"] as! String
        self.userProfilePic = thisUserProfile["profile_picture"] as! String
        self.uid = thisUserProfile["id"] as! String
        self.startListeningToConversations()

        
        setUpNavigationBar()
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
        self.performSegue(withIdentifier: "chatToSettings" , sender: self) //pass data over to
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
    
    func startListeningToConversations() {   //get all the conversations where this current user is a participant of, add
        baseDatabaseReference.collection("conversations").whereField("participants", arrayContains: self.uid).order(by: "last_message_millis", descending: true).addSnapshotListener(){ (querySnapshot, err) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").getDocument { (document, error) in
                if let document = document, document.exists {
                    self.requestCount = document.data()!
                } else {
                    //just empty
                }
                
                
                snapshot.documentChanges.forEach { diff in //FOR EACH individual conversation the user has, when its added
                    
                    print("active chats: ", self.activeChats)
                    
                    if (diff.type == .added) {
                        self.activeChats.append(diff.document.data())
                        print("active chats added: ", self.activeChats)

//                        self.configureTableView()
                        self.checkIfShowtableView()
                        self.tableView.reloadData() //reload rows and section in table view
                    }
                    
                    if (diff.type == .modified) { //FOR EACH!!!!!!!! individual conversation the user has, when its modified, we enter this
                        print("modified:")
                        let modifiedData = diff.document.data()
                        let modifiedID = modifiedData["id"]
                        let posModified = self.locateIndexOfConvo(id: modifiedID as! String) //with the conversation ID, I get the index of that conversation in the active chats array
                        let originalData = self.activeChats[posModified]
                        //only if there is a new message, force the message count to be an int
                        if(modifiedData["message_count"] as! Int  != originalData["message_count"] as! Int ){
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
                            self.checkIfShowtableView()
                            self.tableView.reloadData()
                        }
                        print("active chats modified: ", self.activeChats)

                    }
                    
                    //if a message was removed we enter this
                    if (diff.type == .removed) {
                        print("As soon as it enters removed ", self.activeChats)

                        //TODO: remove the actual conversation that was removed from android.
                        //TODO: start here tomorrow find out why its calling modified and removed
                        let modifiedData = diff.document.data()
                        let modifiedID = modifiedData["id"]
                        let posModified = self.locateIndexOfConvo(id: modifiedID as! String) //with the conversation ID, I get the index of that conversation in the active chats array
                        self.activeChats.remove(at: posModified)
                        
                        self.checkIfShowtableView()
                        self.tableView.reloadData() //reload rows and section in table view
                    }
                }
            }
        }
        
        self.checkIfShowtableView()
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
    }
    
    func locateIndexOfConvo (id:String) -> Int { //function used to located the index of the conversation from the activeChats array
        var position = 0
        for (index, chat) in self.activeChats.enumerated(){    //for every chat the user is part of
            if(id == chat["id"] as! String){  //if the chat has the same id as the modifiedID passed in
                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
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
        self.conversationID = self.activeChats[indexPath.row]["id"] as! String    //use currentley clicked index to get conversation id
        //pass the conversationID through and intent
        self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass data over to
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
        if (posInConversation != -1){
            //if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
            if(currentConversation["last_message_author"] as! String == self.thisUserProfile["id"] as! String){
                cell.lastMessage?.font = UIFont(name:"Cordia New", size: 25.0)
            }else{//if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
                var lastMsgCounts = [CLong]()
                lastMsgCounts = currentConversation["last_message_counts"] as! [CLong]
                if(lastMsgCounts.count >= 0){    //make sure there is actually something that exists in last_message_count
                    thisUsersLastCount = lastMsgCounts[posInConversation]
                    let actualMsgCount = currentConversation["message_count"] as! CLong
                    if(actualMsgCount >= 0 && thisUsersLastCount < actualMsgCount){
                        cell.lastMessage?.font = UIFont(name:"Cordia New Bold", size: 25.0)
//                        self.setMessageNotif = true                              //if bold, set the message notification
                        self.tabBarController?.tabBar.items![0].image = UIImage(named: "chat_notification")
                    }else{
                        cell.lastMessage?.font = UIFont(name:"Cordia New", size: 25.0)
//                        self.setMessageNotif = false                             //if not bold,remove the essage ntofication
                        self.tabBarController?.tabBar.items![0].image = UIImage(named: "chat")
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
        self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).delete()
        
        //request lists deletion... basically get rid of the requests from both the sender adn reciever
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String)
            .collection("userlists").document("requests").updateData([requesteeId: FieldValue.delete()])
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(requesteeId)
            .collection("userlists").document("requests").updateData([self.thisUserProfile["id"] as! String: FieldValue.delete()])
        
        //TODO: delete the collection messages of the conversation from Firestore probably using a cloud function since the subcollection is still there even if convo gone
        //TODO: delete the conversation row from the RecyclerView
    }
    
    
    
    //actually acccept the request amde to chat and be friends
    func acceptRequest(){
        let docData = [String: Any]()   //used to set the hashmap when there is no blocked_by list that exists for this user
        
        self.thisCell!.hideRequestLayout()
        
        
        var requesteeId = getOtherParticipantId(currentConversation: self.thisConversation)
        self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["is_request":false])
        
        
        //one person friend list
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                //nothing if doc exists
            } else {
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").setData(docData)
            }
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").updateData([requesteeId: self.thisConversation["id"] as! String])
        }
        
        
        
        //others friend list
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                //nothing if dox exists
            } else {
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").setData(docData)
            }
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(requesteeId).collection("userlists").document("friends").updateData([self.thisUserProfile["id"] as! String: self.thisConversation["id"] as! String])
        }
        
        
        
        //deleting requests since there is no more requst if its been accepted
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").updateData([requesteeId: FieldValue.delete() ])
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(requesteeId).collection("userlists").document("requests").updateData([self.thisUserProfile["id"] as! String: FieldValue.delete() ])
        
        self.checkForGroupAndSetName(cell: self.thisCell!, currentConversation: self.thisConversation)
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Support Functions
    
    func setPictureAndLastMessage(cell: ConversationCell, currentConversation: Dictionary<String,Any>){ //settting the picture and the last message of the current dell that is displayed
       
        var authorProfilePicLoc = ""
        let storageRef = self.baseStorageReference.reference()
        var lastMessageAuthor = currentConversation["last_message_author"] as! String //the author of the last message that was sent
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
                    if(participant == lastMessageAuthor ){  //if the participant is same as last message author
                        lastMessageAuthorPos = index  //position of the last message author
                        break
                    }
                }
                //setting the last message of that cell to be the name of the last author with the corresponding message that he sent
                if(!participantNames.isEmpty){
                    //TODO: figure out if we need the same stuff as in the andoird version: i.e. "R.string.conversation_adapter_last_message"
                    let lastMessageString = participantNames[lastMessageAuthorPos] +  ": " + String(currentConversation["last_message"] as! String)
                    cell.lastMessage.text = lastMessageString
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
                storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
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
                storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        cell.img.image  = UIImage(data: data!)
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
                    thisUserRequested = self.requestCount[otherUserId] as! Bool
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
                    if(self.thisUserProfile["id"] as! String != participant){  //find other participant pos in array
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
        var participants = conversation["participants"] as! [String]
        var position = 0
        if(participants.count > 0) {
            for (index, participant) in participants.enumerated(){    //for every chat the user is part of
                if(self.thisUserProfile["id"] as! String == participant){  //if the chat has the same id as the modifiedID passed in
                    position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
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
