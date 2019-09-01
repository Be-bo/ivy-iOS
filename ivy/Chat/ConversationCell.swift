//
//  ConversationCell.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class ConversationCell: UITableViewCell {
    
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var thisConversation = Dictionary<String, Any>()
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var lastMessage: StandardLabel!
    @IBOutlet weak var groupSymbol: UIImageView!
    @IBOutlet weak var reject: UIButton!
    @IBOutlet weak var accept: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUp(){
        self.lastMessage.numberOfLines = 1
        self.img.layer.masksToBounds = true
        self.img.layer.cornerRadius = self.img.bounds.width / 2
        self.groupSymbol.isHidden = true    //group symbol hidden by default
        self.accept.isHidden = true
        self.reject.isHidden = true
    }
    
    func hideRequestLayout() {
        accept.isHidden = true
        reject.isHidden = true
    }
    
    func showRequestLayout(){
        accept.isHidden = false
        reject.isHidden = false
    }
    
    
    @IBAction func onClickAccept(_ sender: Any) {
        self.acceptRequest()
    }
    
    
    @IBAction func onClickReject(_ sender: Any) {
        self.rejectRequest()
    }
    
    //populate the data that will need to actually accept or reject the request
    func setInfo(thisConversation:Dictionary<String, Any>, thisUserProfile:Dictionary<String, Any>){
        self.thisUserProfile = thisUserProfile
        self.thisConversation = thisConversation
    }
    
    //actually acccept the request amde to chat and be friends
    func acceptRequest(){
        let docData = [String: Any]()   //used to set the hashmap when there is no blocked_by list that exists for this user
        
        self.hideRequestLayout()


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
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
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

        self.checkForGroupAndSetName(currentConversation: self.thisConversation)
    }
    
    //reject the request made to chat and be friends
    func rejectRequest() {
        self.hideRequestLayout()
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
    
    
    
    
    
    
    //just like chat.swift
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
    
    
    
    
    //same as in chat.swift
    //check if its a group conversation and if so set the name of that group conversation
    func checkForGroupAndSetName(currentConversation: Dictionary<String,Any> ){
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
        //cehck f its a 1-1 chat or if its a group chat
        var isBaseConv = false
        if currentConversation["is_base_conversation"] is Bool{ //if its an isntance of a boolean
            isBaseConv = currentConversation["is_base_conversation"] as! Bool
        }
        //null pointer checks
        if (!participants.isEmpty && !participantNames.isEmpty && participantNames.count > 0 && participants.count > 0){
            //if group convo
            if (participants.count > 2){
                self.groupSymbol.isHidden = false   //show group symbol
                self.name.text = currentConversation["name"] as? String //set group name for that cell
            }else if (participants.count == 2 && isBaseConv){ //else 1-1 chat
                self.groupSymbol.isHidden = true    //not group
                var otherParticipantName = currentConversation["name"] as? String
                
                for (index, participant) in participants.enumerated(){
                    if(self.thisUserProfile["id"] as! String != participant){  //find other participant pos in array
                        otherParticipantName = participantNames[index]  //using that participants index get this name and set it
                    }
                }
                self.name.text = otherParticipantName
            }
            else {
                self.groupSymbol.isHidden = false
                self.name.text = currentConversation["name"] as? String
            }
        }
    }
    
    
    
    
}
