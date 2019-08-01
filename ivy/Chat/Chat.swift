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
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    var activeChats: [Dictionary<String, Any>] = []
    var conversations: [String: Int] = [:]  //Format: "conversationID":"messageCount"
//    var conversations = ["1"]
    var uid = ""    //user id for the authenticated user
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the conversations that are active for the current user
        if Auth.auth().currentUser != nil {
            print("user is signed in")
            let user = Auth.auth().currentUser  //get the object representing the user
            if let user = user {
                uid = user.uid
                // ...
            }
            
            //get reference corresponding to currentley active users conversations , then get the fields of that document
            var chatDocRef =  baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(self.uid).collection("userlists").document("conversations")
            chatDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    //for each seperate chat, add if to conversations so we can iterate through that later when displaying the active conversations
                    for data in document.data()!{
                        self.conversations.updateValue(data.value as! Int, forKey: data.key)
                    }
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                    self.loadData() //call load data here to ensure all the ccurrentley active conversations are first loaded.
                    self.loadData() //call load data here to ensure all the ccurrentley active conversations are first loaded.

                } else {
                    print("Document does not exist")
                }
            }

            print("conversations", self.conversations)
            
            
            
        } else {
            print("no user signed in")
        }
//        self.loadData() //call load data here to ensure all the ccurrentley active conversations are first loaded.

    }
    
    
    
    var count = 0   //count since its always the third document thats the most recentley changed one

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
                
                //TODO start here tomorrow.
               //FOR EACH!!!!!!!! individual conversation the user has, when its modified, we enter this
                if (diff.type == .modified) {
                    self.count = self.count + 1

                    
                    if (self.count == 3){
                        let modifiedData = diff.document.data()
                        let modifiedID = modifiedData["id"]

                    
//                    let modifiedData = diff.document.data()
//                    let modifiedID = modifiedData["id"]
//                    var modifiedData: Dictionary<String, Any> = diff.document.data()
//                    var index = modifiedData.startIndex
//                    print("index here", index)
                    
                        var newOrder: [Dictionary<String, Any>] = self.activeChats
                    
//                    var modifiedID = modifiedData["id"]
//                    print("modifiedID", modifiedID)
//                    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//                    print("Modified data: \(diff.document.data())")
//                    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

                    
                    //with the conversation ID, I get the index of that conversation in the active chats array
                        let posModified = self.locateIndexOfConvo(id: modifiedID as! String)
                        
                        //TODO figure out why the position modified always increases
                        print("position modified: ", posModified)
                        
                        //then I wanna replace that entry with the new modifiedData that I recieve upon a new message
                        for index in stride(from: posModified, to: 0, by: -1) {
                            newOrder.insert(newOrder.remove(at: (index-1) ), at: (index))
                        }


                        newOrder[0] = modifiedData  //replace the 0th entry of the array
                        
//                        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//                        print("newOrder0", newOrder[0])
//                        print("newOrder1", newOrder[1])
//                        print("newOrder2", newOrder[2])
//                        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                        
                        
                        self.activeChats.removeAll()
                        self.activeChats.append(contentsOf: newOrder)
                        newOrder.removeAll()
                        self.tableView.reloadData() //reload rows and section in table view
                        self.count = 0
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
    
    
    
    //TODO start here tomorrow inspecting if we can return the position or not
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
        return self.conversations.count
    }
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        var lastMessage = self.activeChats[indexPath.row]["last_message"] as! String
        var lastMessageSenderID = self.activeChats[indexPath.row]["last_message_author"] as! String //the author of the last message that was sent
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
                        cell.name.text = self.activeChats[indexPath.row]["name"] as! String     //name of the chat this user is involved in
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)

    }
    
    
    
}
