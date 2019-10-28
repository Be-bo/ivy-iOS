//
//  addParticipantPopUPViewController.swift
//  ivy
//
//  Created by paul dan on 2019-08-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class addParticipantPopUPViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

    //https://www.youtube.com/watch?v=FgCIRMz_3dE
    //TODO: use the above video to implement the final transition effects he has if he wants
    //TODO: find a way to disable clicking anywhere else
    
    //initializers
    var thisUserProfile = Dictionary<String, Any>()     //holds the current user profile
    var thisConversation = Dictionary<String, Any>()    //this current conversationboject
    var thisConvId = ""
    var thisUni = ""
    var thisUserId = ""
    var addTheseFriends = [Dictionary<String, String>]()    //array containing the friends they actually wanna add to the conversation in format: "id":"name"
    var friendsToDisplay = [Dictionary<String, Any>()]
    var allPossibleFriends = [Dictionary<String, Any>]()    //all possible friends that can be added to the conversation
    var friendsConvList = Dictionary<String, Any>()
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        if let thisCon = thisConversation["id"] as? String, let thisUn = thisUserProfile["uni_domain"] as? String, let thisUs = thisUserProfile["id"] as? String{
            thisUni = thisUn
            thisUserId = thisUs
            thisConvId = thisCon
            loadFriends()
            self.configureTableView()
        }
    }
    
    //actually load this current users friends
    func loadFriends() {
        //query to get the friends this current user has
        baseDatabaseReference.collection("universities").document(thisUni).collection("userprofiles").document(thisUserId).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                self.friendsConvList = document.data()!
                var participants = [String]()   //arraylist of strings
                participants = self.thisConversation["participants"] as! [String]
                for (key,value) in self.friendsConvList{
                    if(!participants.contains(key)){
                        self.baseDatabaseReference.collection("universities").document(self.thisUni).collection("userprofiles").document(key).getDocument { (document, error) in
                            if let document = document, document.exists {
                                if(document.data() != nil && document.exists) {
                                    self.allPossibleFriends.append(document.data()!)
                                    self.friendsToDisplay.append(document.data()!)
                                    self.tableView.reloadData()
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
    }
    
    
    @IBAction func onClickDone(_ sender: Any) {
        addParticipants()
    }
    
    //actually add the participants to the database and start a new chat with those participants
    func addParticipants(){
        var idAL = [String]()   //arraylist of strings
        var nameAL = [String]()   //arraylist of strings

        if(self.addTheseFriends.count > 0){ //if they actually have one friend to add to the conversation

            for profile in self.addTheseFriends{
                idAL.append(profile["id"] as! String)
                nameAL.append(profile["first_name"] as! String)
            }

            //if its a base conversation
            if (self.thisConversation["is_base_conversation"] as! Bool == true  ){
                createNewGroupConversation(idAL: idAL, nameAL: nameAL)
            }else{  //its not a base conversation
                addParticipantsToThisConversation(idAL: idAL, nameAL: nameAL)
            }
        }
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
        
    }
    
    //method that just adds users to this conversation since its not a base conversation and we dont need to start a brand new conversation
    func addParticipantsToThisConversation(idAL: [String] , nameAL: [String]) {

        let idAL = idAL
        let nameAL = nameAL
        
        print("Existing conversation :", idAL)
        
        var counts = [CLong]()   //arraylist of Longs
        for _ in idAL { //for every id present in the array of id's we wish to add to the conversation
            print("enter here")
            counts.append(0)
        }
        print("counts:", counts)

        //arrayUnion doesnt work on already existing values so if all the message counts are 0 we can't add 0 again, so we gotta extract the already existing array then append to that and re-add it all
        var messageCounts = self.thisConversation["last_message_counts"] as! [CLong]
        messageCounts.append(contentsOf: counts)
        baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData([
            "last_message_counts": messageCounts,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        baseDatabaseReference.collection("conversations").document(thisConvId).updateData(["participants": FieldValue.arrayUnion(idAL)])
        baseDatabaseReference.collection("conversations").document(thisConvId).updateData(["participant_names": FieldValue.arrayUnion(nameAL)])
    }
    
    
    //now that we have all the participants and their name, we can actually create the message object and
    func createNewGroupConversation(idAL: [String] , nameAL: [String]) {
        //make the variables mutable by redefining these local ones to be the variables apsssed in
        var idAL = idAL
        var nameAL = nameAL

        
        print("self.thisConversation[participant_names]",self.thisConversation["participant_names"] as! [String] )
        print("self.thisConversation[participants]",self.thisConversation["participants"] as! [String] )
        
        var participantNameArray = [String]()
        var participantIDArray = [String]()
        
        participantNameArray = self.thisConversation["participant_names"] as! [String]
        participantIDArray = self.thisConversation["participants"] as! [String]
        print("participantNameArray", participantNameArray)
        print("participantIDArray", participantIDArray)

        //add participants on this current convereation to the new one thats gonna be created
        for name in participantNameArray{
            nameAL.insert(name, at: 0)
        }
        for id in participantIDArray{
            idAL.insert(id, at: 0)
        }
        
        
        var convId = baseDatabaseReference.collection("conversations").document().documentID
        var newConversation = Dictionary<String, Any>() //hashmap containing the new object that will be created
        var lastMsgCounts = [CLong]()   //arraylist of Longs
        var mutedBy = [String]()   //arraylist of Strings
        for _ in idAL { //for every id present in the array of id's we wish to add to the conversation
            lastMsgCounts.append(0)
        }
        newConversation["id"] = convId
        newConversation["name"] = ((self.thisUserProfile["first_name"] as! String) + "'s Group Conversation")
        newConversation["is_request"] = false
        newConversation["creation_time"] = Date().millisecondsSince1970    //seconds * 1000 = milliseconds
        newConversation["last_message_millis"] = Date().millisecondsSince1970
        newConversation["last_message"] = "New Group Chat!"
        newConversation["last_message_author"] = thisUserId
        newConversation["message_count"] = 0
        newConversation["is_base_conversation"] = false
        newConversation["participants"] = idAL
        newConversation["participant_names"] = nameAL
        newConversation["last_message_counts"] = lastMsgCounts
        newConversation["muted_by"] = mutedBy
        baseDatabaseReference.collection("conversations").document(convId).setData(newConversation) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.leaveForNewConversation(convId: convId)
            }
        }
    }
    
    //open up the new conversationupon starting it
    func leaveForNewConversation(convId: String) {
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
    }
    
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AddParticipantTableViewCell", bundle: nil), forCellReuseIdentifier: "AddParticipantTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPossibleFriends.count
    }
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddParticipantTableViewCell", for: indexPath) as! AddParticipantTableViewCell
        cell.selectionStyle = .none
        
        let friendsname = String(self.allPossibleFriends[indexPath.row]["first_name"] as! String) + " " + String(self.allPossibleFriends[indexPath.row]["last_name"] as! String) //the author of the last message that was sent
        
        let friendpicloc = "userimages/" + String(self.allPossibleFriends[indexPath.row]["id"] as! String) + "/preview.jpg"

        // Create a storage reference from our storage service
        let storageRef = self.baseStorageReference.reference()
        let storageImageRef = storageRef.child(friendpicloc)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                //actually populate the cell data, done here to avoid returning the cell before the document data is pulled async
                cell.nameLabel.text = friendsname     //name of the chat this user is involved in
                cell.img.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
            }
        }
        
        if let id = self.allPossibleFriends[indexPath.row]["id"] as? String, let firstName = self.allPossibleFriends[indexPath.row]["first_name"] as? String{ //either display or hide checkmark based on whether the user's been selected in the past
            let idName = ["id": (id) , "first_name": (firstName)]
            if (self.addTheseFriends.contains(idName)){
                cell.checkBox.image = UIImage(named: "check")
            }else{
                cell.checkBox.image = nil
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)

        let cl = tableView.cellForRow(at: indexPath) as! AddParticipantTableViewCell
        
        //extract the name and id of the user they just clicked on to be able to add them later to the conversation
        var nameAndID = Dictionary<String, String>()
        nameAndID =  ["id": (self.allPossibleFriends[indexPath.row]["id"] as! String) , "first_name": (self.allPossibleFriends[indexPath.row]["first_name"] as! String)]  //format: "id":"first_name"
        

        //if they click on the same person again then remove ir from the array and get rid of checkmark
        if (addTheseFriends.contains(nameAndID)){
            let index = self.addTheseFriends.firstIndex(of: nameAndID)
            self.addTheseFriends.remove(at: index!)
            cl.checkBox.image = nil
        }else{
             self.addTheseFriends.append(nameAndID)
            cl.checkBox.image = UIImage(named: "check")
        }
    }
}

