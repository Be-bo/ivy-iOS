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
    let baseStorageReference = Storage.storage()    //reference to storage
    var uid = ""    //user id for the authenticated user
    var conversationID = "" //holds the conversation id of the currentley active conversation.
    var messages: [Dictionary<String, Any>] = []//holds all the message DOCUMENTS for this specific conversation

    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure the user is signed in before trying to get data
        if Auth.auth().currentUser != nil {
            print()
            let user = Auth.auth().currentUser  //get the object representing the user
            if let user = user {
                uid = user.uid
                if(conversationID !=  nil && conversationID != "") {startListeningToChangesInThisConversation()}
            }
        } else {
            print("no user signed in")
        }
        
        
        
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
            
            
        }
        
    }
    
    //used to get the messages that are present within the current conversation
    func startListeningToChangesInThisConversation() {
//        baseDatabaseReference.collection("conversations").document(self.conversationID).addSnapshotListener(DocumentSnapshot, error)
        print("self.conversationID", conversationID)
        baseDatabaseReference.collection("conversations").document(self.conversationID).collection("messages").order(by: "creation_time", descending: false).addSnapshotListener(){ (querySnapshot, err) in
            
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
        
        
        var lastMessage = self.messages[indexPath.row]["message_text"] as! String
        var lastMessageSenderID = self.messages[indexPath.row]["author_id"] as! String //the author of the last message that was sent
        var lastMessageAuthor = ""
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        //        print("last message sender id:", lastMessageSenderID)
        
        //use ID to extract name of author
        var lastMessafeRef =  baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(lastMessageSenderID)
        lastMessafeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                lastMessageAuthor =  document.get("first_name") as! String //first name of last message author
                authorProfilePicLoc = document.get("profile_picture") as! String //location of profile pic in storage
                
                // Create a storage reference from our storage service
                var storageRef = self.baseStorageReference.reference()
                var storageImageRef = storageRef.child(authorProfilePicLoc)
                var lastMessageString = lastMessageAuthor + ": " + lastMessage //last message is a combination of who sent it attached with what message they sent.
                
                //                print("storage image reference", storageImageRef)
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
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
    



}
