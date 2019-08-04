//
//  ChatRoom.swift
//  ivy
//
//  Created by paul dan on 2019-08-01.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore

class ChatRoom: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //initializers
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()         //reference to storage
    var uid = ""                                        //user id for the authenticated user
    var messages: [Dictionary<String, Any>] = []        //holds all the message DOCUMENTS for this specific conversation
    var thisUserProfile = Dictionary<String, Any>()     //holds the current user profile
    var thisConversation = Dictionary<String, Any>()    //this current conversationboject
    var firstDataAquisition = true                      //to esnure we only load the converesation object once
    var conversationID = ""                             //hold the id of the current conversation
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("THIS USER PROFILE", self.thisUserProfile)
        self.startListeningToChangesInThisConversation()
        
        
        
    }
    
 
    
    //when the user clicks the send message button
    @IBAction func onClickSendMessage(_ sender: Any) {
        sendMessage()
    }
    
    //actually sends the message to the conversation they are clicked on
    func sendMessage() {
        let inputMessage = messageTextField.text //extract the text field input
        if(inputMessage != ""){ //if not empty
            messageTextField.text = "" //reset the message field to be empty
            var message = Dictionary<String, Any>()
            message["author_first_name"] = self.thisUserProfile["first_name"]
            message["author_last_name"] = self.thisUserProfile["last_name"]
            message["author_id"] = self.thisUserProfile["id"] as! String
            message["conversation_id"] = self.thisConversation["id"] as! String
            message["creation_time"] =  String(CACurrentMediaTime() * 1000)    //seconds * 1000 = milliseconds
            message["message_text"] = inputMessage
            message["is_text_only"] = true
            message["file_reference"] = ""
            message["id"] =  NSUUID().uuidString
            
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            print("message object", message)
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        
            baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).collection("messages").document(message["id"] as! String).setData(message)
            baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message_millis": CLong(message["creation_time"] as! String) ])
            baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message": message["message_text"] as! String])
            baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message_author": message["author_id"] as! String])
            baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["message_count": self.messages.count + 1])
            
            let thisUserPos = locateUser(id: thisUserProfile["id"] as! String) //get the position of the user in the array of participants to modify
            if (thisUserPos != 1) {
                var lastMsgCounts = thisConversation["last_message_counts"] as! Array<CLong>
                if(lastMsgCounts != nil) {
                    lastMsgCounts[thisUserPos] = self.messages.count + 1
                    self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message_counts": lastMsgCounts])
                }
            }
            
            //TODO: decide if need to compensatefor listener bug here (Check android for code)
            
            
        }
        
    }
    
    //listen and retrun the up to date conversation object
    func startListeningToChangesInThisConversation() {
        let thisConversationRegistration = baseDatabaseReference.collection("conversations").document(self.conversationID).addSnapshotListener(){ (querySnapshot, err) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            
            if (snapshot.exists) {
                self.thisConversation = snapshot.data()!
                print("self.thisconversation", self.thisConversation)
                
                if(self.firstDataAquisition) {
                    print("first data acquisition ")
                    self.startRetrievingMessages()
                    self.firstDataAquisition = false
                }
                //TODO: decide if setUpActionBar() needs to be called here or not
            }
        }
    }
    
    
    //used to get the messages that are present within the current conversation
    func startRetrievingMessages() {
        baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).collection("messages").order(by: "creation_time", descending: false).addSnapshotListener(){ (querySnapshot, err) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            //FOR EACH individual conversation the user has, when its added
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    self.messages.append(diff.document.data())  //append the message document to the messages array
                    self.configureTableView()
                    self.tableView.reloadData()
                }
            }

        }
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("self.messages.count", self.messages.count)
        return self.messages.count
    }
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let lastMessage = self.messages[indexPath.row]["message_text"] as! String
        print("index path.row", indexPath.row)
        let lastMessageSenderID = self.messages[indexPath.row]["author_id"] as! String //the author of the last message that was sent
        var lastMessageAuthor = ""
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        
        //use ID to extract name of author
        let lastMessafeRef =  baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(lastMessageSenderID)
        lastMessafeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                lastMessageAuthor =  document.get("first_name") as! String //first name of last message author
                authorProfilePicLoc = document.get("profile_picture") as! String //location of profile pic in storage
                
                // Create a storage reference from our storage service
                let storageRef = self.baseStorageReference.reference()
                let storageImageRef = storageRef.child(authorProfilePicLoc)
                let lastMessageString = lastMessageAuthor + ": " + lastMessage //last message is a combination of who sent it attached with what message they sent.
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        //actually populate the cell data, done here to avoid returning the cell before the document data is pulled async
                        cell.name.text = self.messages[indexPath.row]["author_first_name"] as! String     //name of the chat this user is involved in
                        cell.lastMessage.text = lastMessageString  //last message that was sent in the chat
                        cell.img.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        
        
        return cell
    }
    
    func locateUser(id: String) -> Int {
        var position = 0
        var participants = [String]()
        participants = self.thisConversation["participants"] as! [String]
        for (index, chat) in participants.enumerated(){    //for every chat the user is part of
            if(id == chat){  //if the chat has the same id as the modifiedID passed in
                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
            }
        }
        print("position to modify", position)
        return position
    }

//    //function used to located the index of the conversation from the activeChats array
//    func locateIndexOfConvo (id:String) -> Int {
//        var position = 0
//        for (index, chat) in self.activeChats.enumerated(){    //for every chat the user is part of
//            if(id == chat["id"] as! String){  //if the chat has the same id as the modifiedID passed in
//                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
//            }
//        }
//        return position
//    }


}
