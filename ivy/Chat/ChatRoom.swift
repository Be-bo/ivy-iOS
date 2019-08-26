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
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore

class ChatRoom: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //initializers
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()        //reference to storage
    var uid = ""                                        //user id for the authenticated user
    var messages: [Dictionary<String, Any>] = []        //holds all the message DOCUMENTS for this specific conversation
    var thisUserProfile = Dictionary<String, Any>()     //holds the current user profile
    var thisConversation = Dictionary<String, Any>()    //this current conversationboject
    var firstDataAquisition = true                      //to esnure we only load the converesation object once
    var conversationID = ""                             //hold the id of the current conversation
    private var file_attached:Bool = false              //indicating that a file is not attached by default
    var imageByteArray:NSData? =  nil                   //image byte array to hold the image the user wished to upload
    var keyboardHeight:CGFloat = 0
    var otherId=""                                      //other persons id that will be exxtracted when figuring out who your conversating with
    
    
    //holders for image and regular file
    var imagePicked: ((UIImage))?
    var filePicked: ((URL))?
    
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var xButton: UIButton!   //x button that gets shown when a file is attached
    @IBOutlet weak var fileNameLabel: UILabel!  //the label that will display the name of the file thats attached
    @IBOutlet weak var msgFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileBtnHeightConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startListeningToChangesInThisConversation()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        hideKeyboardOnTapOutside()
        setUpKeyboardListeners()
        xButton.isHidden = true //make sure the x button is hidden by default
    }
    
    
    //setup listeners for if they click on actions to show the keyboard, and when they click on button, to hide keyboard
    private func setUpKeyboardListeners(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let kbHeight = keyboardRectangle.height
        self.keyboardHeight = kbHeight
        UIView.animate(withDuration: 0.5){
            self.msgFieldHeightConstraint.constant = self.keyboardHeight
            self.sendBtnHeightConstraint.constant = self.keyboardHeight
            self.fileBtnHeightConstraint.constant = self.keyboardHeight
            self.messageTextField.layoutIfNeeded()
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5){
            self.msgFieldHeightConstraint.constant = 4
            self.sendBtnHeightConstraint.constant = 4
            self.fileBtnHeightConstraint.constant = 4
            self.messageTextField.layoutIfNeeded()
        }
    }
    //all the possible actions that a user can have on the conversation.
    @objc func showActions(){
        var isBaseConv = self.thisConversation["is_base_conversation"] as! Bool
        var isMuted = false
        var mutedBy = self.thisConversation["muted_by"] as! [String]
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        //ADDING ACTIONS TO THE ACTION SHEET
        actionSheet.addAction(UIAlertAction(title: "Add Participants", style: .default, handler: self.onClickAddParticipants))
        actionSheet.addAction(UIAlertAction(title: "Leave Conversation", style: .default, handler: self.onClickLeaveConversation))  //TODO: implement this!!!
        //if the conversation has been muted by atleast one person
        if(mutedBy.count > 0){
            if(mutedBy.contains(self.thisUserProfile["id"] as! String)){ //if you muted the conversation then add the option to unmute instead.
                isMuted = true
                actionSheet.addAction(UIAlertAction(title: "Unmute Conversation", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
            }else{  //the conversation hasn't been muted by anyone
                actionSheet.addAction(UIAlertAction(title: "Mute", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
            }
        }else{  //the conversation hasn't been muted by anyone
            actionSheet.addAction(UIAlertAction(title: "Mute", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
        }
        //if its a base conversation (1-1) then it  will be view member profile, if not then we can view ALL the members part of the conversation
        if(isBaseConv){
            actionSheet.addAction(UIAlertAction(title: "View User's Profile", style: .default, handler: self.onClickViewProfile))
        }else{
            actionSheet.addAction(UIAlertAction(title: "View Participants", style: .default, handler: self.onClickViewParticipants))
            actionSheet.addAction(UIAlertAction(title: "Change Group Name", style: .default, handler: self.onClickChangeGroupName))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Report Conversation", style: .default, handler: self.onClickReportConversation))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    



    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //handling different segue calls based on identitfier
        if segue.identifier == "addParticipantSegue" {
            let vc = segue.destination as! addParticipantPopUPViewController
            vc.thisUserProfile = self.thisUserProfile   //pass the user profile object
            vc.thisConversation = self.thisConversation
        }
        if segue.identifier == "viewFullProfileSegue" {
            let vc = segue.destination as! ViewFullProfileActivity
            vc.isFriend = true
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.otherId
        }
        if segue.identifier == "viewParticipantsSegue" {
            let vc = segue.destination as! viewParticipantsActivity
            vc.thisUserProfile = self.thisUserProfile
            vc.thisConversation = self.thisConversation
        }
        if segue.identifier == "chatToChangeGroupName" {
            let vc = segue.destination as! changeGroupNamePopupViewController
            vc.thisUserProfile = self.thisUserProfile
            vc.thisConversation = self.thisConversation
        }
        
        
        
    }
    
    
    //when they click change group name send them here
    func onClickChangeGroupName(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "chatToChangeGroupName" , sender: self) //pass data over to
    }
    
    //TODO: implement this user leaving the current conversation
    func onClickLeaveConversation(alert: UIAlertAction!) {
        
    }
    

    //participant controller segue to allow them to add more people to the chat
    func onClickAddParticipants(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "addParticipantSegue" , sender: self) //pass data over to
    }
    
    
    //when they click "view participants"
    func onClickViewParticipants(alert: UIAlertAction!){
        self.performSegue(withIdentifier: "viewParticipantsSegue" , sender: self) //pass data over to
    }
    
    //when its a base conversation and they click on the profile to view
    func onClickViewProfile(alert: UIAlertAction!) {
        self.otherId = getOtherParticipant(conversation: self.thisConversation, returnName: false)   //extract other participant id
        if (self.otherId != ""){ //if there is actually someone part of the conversation
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
        }
    }
    
    //helper funtion for view profile that will retrieve the other participant that is active in this conversation
    func getOtherParticipant(conversation: Dictionary<String,Any>, returnName:Bool) -> String {
        let participants = conversation["participants"] as! [String]
        var participantNames = conversation["participant_names"] as! [String]
        var otherParticipantId = ""
        var otherParticipantName = ""
        var returnVal = ""
        for (index, participant) in participants.enumerated() {
            if !(participant == self.thisUserProfile["id"] as! String){
                otherParticipantId = participant
                otherParticipantName = participantNames[index]
                if(returnName) {returnVal = otherParticipantName}
                else{returnVal = otherParticipantId}
            }
        }
        return returnVal
    }
    
    
    //when the user clicks to mute the conversation or to unmute the conversation
    func onClickMuteConversation(isMuted:Bool) -> (_ alertAction:UIAlertAction) -> () {
        var thisUserProfileID = [String]()   //arraylist of strings
        thisUserProfileID.append(self.thisUserProfile["id"] as! String)
        return { alertAction in
            if (isMuted){
                self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["muted_by": FieldValue.arrayRemove(thisUserProfileID) ])
            }else{
                self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["muted_by": FieldValue.arrayUnion(thisUserProfileID )])
            }
        }
    }
    
    //when user clicks report conversaiton
    func onClickReportConversation(alert: UIAlertAction!) {
        var report = Dictionary<String, Any>()
        report["reportee"] = self.thisUserProfile["id"] as! String
        report["report_type"] = "conversation"
        report["target"] = self.thisConversation["id"] as! String  //this current conversation id
        report["time"] = Date().millisecondsSince1970
        let reportId = self.baseDatabaseReference.collection("reports").document().documentID   //create unique id for this document
        report["id"] = reportId
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.thisConversation["id"] as! String).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if(!querySnapshot!.isEmpty){
                    print("You have already reported this conversation.")
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    print("This conversation has been reported.")
                }
            }
        }
    }
    
    
    //when the user clicks the send message button determine if there is a file attached or just a message and send based on that
    @IBAction func onClickSendMessage(_ sender: Any) {
        if(!self.file_attached){ //if file_attached is false then send a message
            sendMessage()
        }else{  //there is a file attached so send a file message instead
            sendFileMessage()
        }
    }
    
    
    //when the user clicks the x button, remove the file, remove the name, collapse both the x and the name
    @IBAction func onClickX(_ sender: Any) {
        self.fileNameLabel.text = nil
        self.fileNameLabel.isHidden = true
        self.xButton.isHidden = true
        self.file_attached = false
        //reset the image and file picked
        self.imagePicked = nil
        self.filePicked = nil
    }
    
    
    
    //when user clicks the add file button then deal with adding a file to the chat and setting file_attached to true
    @IBAction func onClickAttachFile(_ sender: Any) {
        // ---------------------------------------------- OPTION PROMPTING FOR FILE UPLOADING ----------------------------------------------
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        // ---------------------------------------------- IMAGE CHOOSING ----------------------------------------------
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            self.file_attached = true
            
            //Add the image name to the chat so they know what they just attached
            self.fileNameLabel.text = image.accessibilityIdentifier!
            self.fileNameLabel.isHidden = false
            
            //present the x that removes the image & name if clicked on
            self.xButton.isHidden = false
            //set the image picked to be the one chosen by the user so that we can easily access it later
            self.imagePicked = image
            self.filePicked = nil   //clear file picked
        }
        // ---------------------------------------------- IMAGE CHOOSING ----------------------------------------------

        
        // ---------------------------------------------- FILE CHOOSING ----------------------------------------------

        AttachmentHandler.shared.filePickedBlock = { (url) in
            self.file_attached = true
            
            //Add the image name to the chat so they know what they just attached
            self.fileNameLabel.text = url.lastPathComponent
            self.fileNameLabel.isHidden = false
            
            //present the x that removes the image & name if clicked on
            self.xButton.isHidden = false
            
            //set the image picked to be the one chosen by the user so that we can easily access it later
            self.filePicked = url   //url of where the path is on the device
            self.imagePicked = nil //clear image picked incase its not empty
        }
        // ---------------------------------------------- FILE CHOOSING ----------------------------------------------

    }
    

    
    
    
    //send a file over the chat. differentiate b/w image or regular files (pdf's,word docs, etc.)
    func sendFileMessage(){
        
        var inputFileName = self.fileNameLabel.text //save file name
        let storageRef = self.baseStorageReference.reference()
        var filePath = ""
        var byteArray:NSData? =  nil
        var metadata = StorageMetadata()    //decided whether file is image/jpeg or w.e other type
        var uploadTask: StorageUploadTask   //differing upload tasks

        //if image not nill then user self.image, else use file since that must be ethe picked one
        if ( self.imagePicked != nil ){
            metadata.contentType = "image/png" // Create the file metadata TODO: decide if this should be nil and find out how to let firestore decide what content type it should be
            filePath = "conversationfiles/" + String(self.thisConversation["id"] as! String) + "/" + self.imagePicked!.accessibilityIdentifier!  //path of where the files shared for this particular conversation saved at
            byteArray = (self.imagePicked!.jpegData(compressionQuality: 1.0)!) as NSData  //convert to jpeg
            self.fileNameLabel.text = nil //reset variables
            self.xButton.isHidden = true
            self.file_attached = false
            self.fileNameLabel.isHidden = true
        }else{
            //TODO deal with the file byte array and path/what not
            filePath = "conversationfiles/" + String(self.thisConversation["id"] as! String) + "/" + self.filePicked!.lastPathComponent  //path of where the files shared for this particular conversation saved at
            self.fileNameLabel.text = nil //reset variables
            self.xButton.isHidden = true
            self.file_attached = false
            self.fileNameLabel.isHidden = true
        }
        
        let storageLocRef = storageRef.child(filePath) //storeageImageRef now points to the correctspot that this should be save in
        var message = Dictionary<String, Any>()
        message["author_first_name"] = self.thisUserProfile["first_name"]
        message["author_last_name"] = self.thisUserProfile["last_name"]
        message["author_id"] = self.thisUserProfile["id"] as! String
        message["conversation_id"] = self.thisConversation["id"] as! String
        message["creation_time"] =  Date().millisecondsSince1970   //millis
        message["message_text"] =  inputFileName  //filepath
        message["is_text_only"] = false
        message["file_reference"] = filePath
        message["id"] =  NSUUID().uuidString
        
        //different upload task based on if its a file or if its an image
        if ( self.imagePicked != nil ){
            uploadTask = storageLocRef.putData(byteArray! as Data, metadata: metadata) { (metadata, error) in
            }
        }else{
            uploadTask = storageLocRef.putFile(from: self.filePicked!, metadata: nil)
        }
        
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            //update all the data to match accordingly
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).collection("messages").document(message["id"] as! String).setData(message)
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message": message["message_text"] as! String])
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message_author": message["author_id"] as! String])
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message_millis": message["creation_time"] as! Int64  ])
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["message_count": self.messages.count + 1])
            
            //update last message count for this user
            let thisUserPos = self.locateUser(id: self.thisUserProfile["id"] as! String) //get the position of the user in the array of participants to modify
            if (thisUserPos != -1) {
                var lastMsgCounts = self.thisConversation["last_message_counts"] as? [CLong]
                if(lastMsgCounts != nil) {
                    lastMsgCounts![thisUserPos] = self.messages.count + 1
                    self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message_counts": lastMsgCounts])
                }
            }
            //TODO: decide if need to compensatefor listener bug here (Check android for code)
        }
        
        //upload task failed
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    break
                case .unknown:
                    print("unknown error")
                    break
                default:
                    print("retry the upload here if it fails")
                    break
                }
            }
        }
    }
    
    
    
    
    
    //actually sends the message to the conversation they are clicked on
    func sendMessage() {
        
        let inputMessage = messageTextField.text //extract the text field input
        if(inputMessage != ""){ //if not empty
            messageTextField.text = "" //reset the message field to be empty
            var message = Dictionary<String, Any>()
            if (!thisUserProfile.isEmpty){  //make sure there is a user profile that exists
                message["author_first_name"] = self.thisUserProfile["first_name"]
                message["author_last_name"] = self.thisUserProfile["last_name"]
                message["author_id"] = self.thisUserProfile["id"] as! String
                message["conversation_id"] = self.thisConversation["id"] as! String
                message["creation_time"] =  Date().millisecondsSince1970   //seconds * 1000 = milliseconds
                message["message_text"] = inputMessage
                message["is_text_only"] = true
                message["file_reference"] = ""
                message["id"] =  NSUUID().uuidString
                
                baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).collection("messages").document(message["id"] as! String).setData(message)
                baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message_millis": message["creation_time"] as! Int64  ])
                baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message": message["message_text"] as! String])
                baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["last_message_author": message["author_id"] as! String])
                baseDatabaseReference.collection("conversations").document(thisConversation["id"] as! String).updateData(["message_count": self.messages.count + 1])
                
                let thisUserPos = locateUser(id: thisUserProfile["id"] as! String) //get the position of the user in the array of participants to modify
                if (thisUserPos != -1) {
                    var lastMsgCounts = thisConversation["last_message_counts"] as? [CLong]
                    if(lastMsgCounts != nil) {
                        lastMsgCounts![thisUserPos] = self.messages.count + 1
                        self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["last_message_counts": lastMsgCounts])
                    }
                }
                //TODO: decide if need to compensatefor listener bug here (Check android for code)
            }
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
//                print("self.thisconversation", self.thisConversation)
                if(self.firstDataAquisition) {
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
        return self.messages.count
    }
    
    
    
    
    // called for every single cell thats displayed on screen/on reload
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //called for each cell but will only update on the last index of messages since we only want it to update when the users "read" (loaded cell) the last message
        updateLastSeenMessage()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
//        let lastMessageSenderID = self.messages[indexPath.row]["author_id"] as! String //the author of the last message that was sent
        var lastMessageAuthor = ""
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        
        lastMessageAuthor =  self.messages[indexPath.row]["author_first_name"] as! String //first name of last message author
        authorProfilePicLoc = "userimages/" + String(self.messages[indexPath.row]["author_id"] as! String) + "/preview.jpg"
        
        // Create a storage reference from our storage service
        let lastMessage = self.messages[indexPath.row]["message_text"] as! String
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
        
        
        //TODO: figure out how to scroll to the bottom of the chat when you send a new message
        //TODO: figure out the optimization of messages laoded to make sure not all messages are loadede each time a new message comes in
//
//        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
//        self.tableView.setContentOffset(scrollPoint, animated: false)

        
        
        return cell
    }
    
    
    
    
    // used to located the index of the conversation from the activeChats array
    func locateUser(id: String) -> Int {
        var position = 0
        var participants = [String]()
        participants = self.thisConversation["participants"] as! [String]
        for (index, chat) in participants.enumerated(){    //for every chat the user is part of
            if(id == chat){  //if the chat has the same id as the modifiedID passed in
                position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
            }
        }
        return position
    }
    
    
    
    
    //update the last seen message count for this user for this conversations but only once we've loaded all its messages
    func updateLastSeenMessage() {

        if(self.messages.count >= self.thisConversation["message_count"] as! CLong){    //if we have more messages then the amount thats been seen
            var counts = self.thisConversation["last_message_counts"] as? [CLong]
            let participants = self.thisConversation["participants"] as? [String]
            
            //make sure we actually retrieved the data
            if(participants != nil && counts != nil){
                for (index, participant) in participants!.enumerated(){    //for every chat the user is part of
                    if(self.thisUserProfile["id"] as? String == participant){  //if the chat has the same id as the modifiedID passed in
                        counts?[index] = (self.messages.count)
                        //update the array in the db to contain the correct amount of messages now seen by this user
                        self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData([
                            "last_message_counts": counts,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                        break
                    }
                }
                
            }
        }
    }
    
    

}



extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
