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

    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userAuthFirstName = thisUserProfile["first_name"] as! String
        self.userProfilePic = thisUserProfile["profile_picture"] as! String
        self.uid = thisUserProfile["id"] as! String
        self.loadData()
        
    }
    
    
    
    //user profile thats logged in
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
    }
    
    

    //load data realtime from the conversations collection, if any changes are made then execute the chode inside snapshotListener
    func loadData() {   //get all the conversations where this current user is a participant of, add
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
    
    
    
    
    
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let lastMessage = self.activeChats[indexPath.row]["last_message"] as! String
        let lastMessageSenderID = self.activeChats[indexPath.row]["last_message_author"] as! String //the author of the last message that was sent
        let isBaseConversation = self.activeChats[indexPath.row]["is_base_conversation"] as! Bool   //boolean indicating wether its a base conv or not
        var currentConversation = self.activeChats[indexPath.row]  //conversation object which will be passed to the bold checker
        var lastMessageAuthor = "" 
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        
        //use ID to extract name of author
        let lastMessafeRef =  baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(lastMessageSenderID)
        lastMessafeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                lastMessageAuthor =  document.get("first_name") as! String //first name of last message author
                
                
//                authorProfilePicLoc = document.get("profile_picture") as! String //location of profile pic in storage
                authorProfilePicLoc = "userimages/" + (document.get("id") as! String) + "/preview.jpg"
                
                // Create a storage reference from our storage service
                let storageRef = self.baseStorageReference.reference()
                var storageImageRef = storageRef.child(authorProfilePicLoc)
                let lastMessageString = lastMessageAuthor + ": " + lastMessage //last message is a combination of who sent it attached with what message they sent.

                //extract participant names if its a base conversation
                if (isBaseConversation) {
                    
                    //extraction
                    var participantNamesArray = [String]()
                    participantNamesArray = self.activeChats[indexPath.row]["participant_names"] as! [String]
                    
                    //remove this current users name from that array
                    participantNamesArray.removeAll { $0 == self.userAuthFirstName }
                    
                    
                    let nameToSet = participantNamesArray.popLast() //name of user you are conversating with
                    
                    //from name extract his id to be able to get his profile pic location
                    self.baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").whereField("first_name", isEqualTo: nameToSet!)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    var childString = "userimages/" + (document.get("id") as! String) + "/preview.jpg"
                                    storageImageRef = storageRef.child(childString)
                                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                                    storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                        if let error = error {
                                            print("error", error)
                                        } else {
                                            if (self.boldCheck(currentConversation:currentConversation) == true){//make the text bold
                                                cell.lastMessage.text = lastMessageString  //last message that was sent in the chat
                                                cell.lastMessage?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
                                            }else{  //not bold
                                                cell.lastMessage?.font = UIFont(name:"HelveticaNeue", size: 16.0)
                                                cell.lastMessage.text = lastMessageString  //last message that was sent in the chat
                                            }
                                            cell.img.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
                                        }
                                    }
                                }
                            }
                    }
                    cell.name.text = nameToSet      //name of the chat this user is involved in
                }else {
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            if (self.boldCheck(currentConversation:currentConversation) == true){ //make the text bold
                                cell.lastMessage.text = lastMessageString  //last message that was sent in the chat
                                cell.lastMessage?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
                            }else{//text not bold
                                cell.lastMessage.text = lastMessageString  //last message that was sent in the chat
                                cell.lastMessage?.font = UIFont(name:"HelveticaNeue", size: 16.0)
                                
                            }
                            cell.img.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
                        }
                    }
                    let nameToSet = self.activeChats[indexPath.row]["name"] as? String
                    cell.name.text = nameToSet      //name of the chat this user is involved in
                }
            } else {
                print("Document does not exist")
            }
        }
        
        
        
        return cell
    }
    
    
    
    
    
    //triggered when you actually click a conversation from the tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.conversationID = self.activeChats[indexPath.row]["id"] as! String    //use currentley clicked index to get conversation id
        //pass the conversationID through and intent
        self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass data over to
    }
    
    
    
    
    
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatRoom
        vc.conversationID = self.conversationID //set the conversation id of chatRoom.swift to contain the one the user clicked on
        vc.thisUserProfile = self.thisUserProfile   //pass the user profile object 
    }
    
    
    //function that will check whether the message neeeds to be bold or not, based on if the user has read the message or not
    func boldCheck(currentConversation: Dictionary<String,Any> ) -> Bool{
        var boolRet: Bool = false   //false by default so dont bold
        var thisUsersLastCount: CLong
        var posInConversation = locateThisUser(conversation: currentConversation)
        
        if(currentConversation["last_message_author"] as! String == self.thisUserProfile["id"] as! String){   //if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
            boolRet = false
        }else{//if the last message for the given conversation wasn't sent by this user determine if they've seen it or not and highlight it accordingly
            var lastMsgCounts = [CLong]()
            lastMsgCounts = currentConversation["last_message_counts"] as! [CLong]
            print("pos in conversation", posInConversation)
            print("last message counts", lastMsgCounts)
            
            if(lastMsgCounts.count > 0){    //make sure there is actually something that exists in last_message_count
                thisUsersLastCount = lastMsgCounts[posInConversation]
                var actualMsgCount = currentConversation["message_count"] as! CLong
                if(actualMsgCount != nil && thisUsersLastCount < actualMsgCount){
                    boolRet = true
                }else{
                    boolRet = false
                }
            }
        }
        return boolRet
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
    
}
