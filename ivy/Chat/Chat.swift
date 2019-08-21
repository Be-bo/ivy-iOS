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
    
    //initializers
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    var activeChats: [Dictionary<String, Any>] = []
    var conversations: [String: Int] = [:]  //Format: "conversationID":"messageCount"
    var uid = ""    //user id for the authenticated user
    var conversationID = ""
    var userAuthFirstName = ""  //first name of the authenticated user
    var userProfilePic = ""
    private var thisUserProfile = Dictionary<String, Any>()
    private var requestCount = Dictionary<String, Any>()
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userAuthFirstName = thisUserProfile["first_name"] as! String
        self.userProfilePic = thisUserProfile["profile_picture"] as! String
        self.uid = thisUserProfile["id"] as! String
        self.loadRequestCount() //execute startListeningToConversations() in loadRequestCount to ensure all the requests are loaded first
        
        setUpNavigationBar()
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        
        // this retarded bs is not working
        let settingsBtn = SettingsButton()
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    
    
    //user profile thats logged in
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
    }
    
    

    //load data realtime from the conversations collection, if any changes are made then execute the chode inside snapshotListener
    func startListeningToConversations() {   //get all the conversations where this current user is a participant of, add
        baseDatabaseReference.collection("conversations").whereField("participants", arrayContains: self.uid).order(by: "last_message_millis", descending: true).addSnapshotListener(){ (querySnapshot, err) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            //FOR EACH individual conversation the user has, when its added
            snapshot.documentChanges.forEach { diff in
                
                if (diff.type == .added) {
                    self.activeChats.append(diff.document.data())
                    self.configureTableView()
                    self.tableView.reloadData() //reload rows and section in table view
                }
                
               //FOR EACH!!!!!!!! individual conversation the user has, when its modified, we enter this
                if (diff.type == .modified) {
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
                        self.tableView.reloadData()
                    }
                }
                
                //if a message was removed we enter this
                if (diff.type == .removed) {
                    print("Removed chat: \(diff.document.data())")
                    self.tableView.reloadData() //reload rows and section in table view
                }
            }
        }
    }
    
    
    
    //function used to located the index of the conversation from the activeChats array
    func locateIndexOfConvo (id:String) -> Int {
        var position = 0
        for (index, chat) in self.activeChats.enumerated(){    //for every chat the user is part of
            if(id == chat["id"] as! String){  //if the chat has the same id as the modifiedID passed in
                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
            }
        }
        return position
    }
    
    
    
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeChats.count
    }
    
    //triggered when you actually click a conversation from the tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.conversationID = self.activeChats[indexPath.row]["id"] as! String    //use currentley clicked index to get conversation id
        //pass the conversationID through and intent
        self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass data over to
    }
    
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
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
                    }else{
                        cell.lastMessage?.font = UIFont(name:"Cordia New", size: 25.0)
                    }
                }
            }
            
            
        }
        
        return cell
    }
    
    
    
    
    
    //settting the picture and the last message of the current dell that is displayed.
    func setPictureAndLastMessage(cell: ConversationCell, currentConversation: Dictionary<String,Any>){
       
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
    
    
    
    
    //check if this cell shuld have the checkmark and x for accepting the message request or denying the message request.
    func checkForRequest(cell: ConversationCell, currentConversation: Dictionary<String,Any> ){
        
        var thisUserRequested = true
        
        //extracting which user requested versus which user did the requesting
        if (currentConversation["is_request"] is Bool){
            let isReq = currentConversation["is_request"] as? Bool
            if (isReq != nil && isReq!){
                let otherUserId = self.getOtherParticipantId(currentConversation: currentConversation)   //extract his id
                print("other user id", otherUserId)
                
                print("is ", self.requestCount)
                
                if (!self.requestCount.isEmpty && self.requestCount[otherUserId] is Bool && self.requestCount[otherUserId] != nil){
                    print("enter here")
                    thisUserRequested = self.requestCount[otherUserId] as! Bool
                }
            }
        }
        if (!thisUserRequested){
            print("this user re", thisUserRequested)
            let name  = cell.name.text
            cell.name.text = "pending: " + name!  //TODO: decide if we need this to be setup the way it is onn adnroid: i.e "R.string.conversation_adapter_pending,"
            cell.showRequestLayout()
        }else{
            cell.hideRequestLayout()
        }
        
    }
    
    

    
    
    //check if its a group conversation and if so set the name of that group conversation
    func checkForGroupAndSetName(cell: ConversationCell, currentConversation: Dictionary<String,Any> ){
      
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
        
        //cehck if its a 1-1 chat or if its a group chat
        var isBaseConv = false
        if currentConversation["is_base_conversation"] is Bool{ //if its an isntance of a boolean
            isBaseConv = currentConversation["is_base_conversation"] as! Bool
        }
        

        
        //null pointer checks
        if (!participants.isEmpty && !participantNames.isEmpty && participantNames.count > 0 && participants.count > 0){
            
            //if group convo
            if (participants.count > 2){
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
            }
    
            else {
                cell.groupSymbol.isHidden = false
                cell.name.text = currentConversation["name"] as? String
            }
        }
    }
    
    
    
    

    
    
    
    
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatRoom
        vc.conversationID = self.conversationID //set the conversation id of chatRoom.swift to contain the one the user clicked on
        vc.thisUserProfile = self.thisUserProfile   //pass the user profile object 
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
    
    //return the other participant of this 1-1 chat
    func getOtherParticipantId(currentConversation: Dictionary<String,Any>) -> String {
        
        
        //if there is participants then add them to aprticipants variable, else its empty
        var participants = [String]()
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
    
    
    //loading the request counts
    func loadRequestCount(){
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").getDocument { (document, error) in
            if let document = document, document.exists {
                self.requestCount = document.data()!
            } else {
                //just empty
            }
            self.startListeningToConversations()

        }
        
    }
    
    
    
}
