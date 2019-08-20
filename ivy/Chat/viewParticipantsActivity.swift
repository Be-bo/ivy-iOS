//
//  viewParticipantsActivity.swift
//  ivy
//
//  Created by paul dan on 2019-08-18.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//this file deals with showing all the participants that are part of a certain cnversation

import Foundation
import UIKit
import Firebase
import FirebaseStorage



class viewParticipantsActivity: UIViewController , UITableViewDelegate, UITableViewDataSource{

    
    
    var thisUserProfile = Dictionary<String,Any>()                              //current user that wants to view another profile
    var thisConversation = Dictionary<String, Any>()                            //this current conversationboject
    var participants = [String]()                                               //participants of this conversation
    var participantNames = [String]()                                           //participant names of this conversation
    var otherId = ""                                                            //other guys id of when you click on a certain profile to view it
    let baseStorageReference = Storage.storage()                                //reference to storage

    @IBOutlet weak var tableView: UITableView!  //table view that will hold all the participants part of this convo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadParticipants()
    }
    
    //---------------------------------ACTION BAR STUFF---------------------------------



    
    //---------------------------------ACTION BAR STUFF---------------------------------

    
    
    func loadParticipants() {
        //if there is actually a profile and its part of a conversation
        if (!self.thisUserProfile.isEmpty && !self.thisConversation.isEmpty) {
            self.participants = self.thisConversation["participants"] as! [String] //get other participants
            self.participantNames = self.thisConversation["participant_names"] as! [String]
            //make sure we have participants that actually exist
            if(!self.participants.isEmpty && !self.participantNames.isEmpty){
                self.tableView.reloadData() //reload recycle view with data
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
        return self.participants.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        // Create a storage reference from our storage service to get the preview profile picture for the current person your talking with
        let participantProfilePicLoc = "userimages/" + self.participants[indexPath.row] + "/preview.jpg"
        let storageRef = self.baseStorageReference.reference()
        let storageImageRef = storageRef.child(participantProfilePicLoc)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                //actually populate the cell data, done here to avoid returning the cell before the document data is pulled async
                cell.name.text = self.participantNames[indexPath.row]
                cell.lastMessage.text = ""
                cell.img.image  = UIImage(data: data!) //image corresponds to the last_message_author profile pic
            }
        }
        return cell
    }
    
    
    //triggered when you actually click a conversation from the tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.otherId = self.participants[indexPath.row]
        if (self.otherId != ""){ //if there is actually someone part of the conversation
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
        }
    }
    
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewFullProfileActivity
        vc.thisUserProfile = self.thisUserProfile
        vc.otherUserID = self.otherId
    }
    



}
