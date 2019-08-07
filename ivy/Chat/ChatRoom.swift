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
    private var file_attached:Bool = false  //indicating that a file is not attached by default
    var imageByteArray:NSData? =  nil   //image byte array to hold the image the user wished to upload
    var keyboardHeight:CGFloat = 0
    
    
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
    }
    
    
    
    
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
    
    
    
    
    
    @objc func showActions(){
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        actionSheet.addAction(UIAlertAction(title: "Add Participants", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Leave Conversation", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Mute", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "View Members", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Report Conversation", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    



//called every single time a segway is called
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! addParticipantPopUPViewController
    vc.thisUserProfile = self.thisUserProfile   //pass the user profile object
    vc.thisConversation = self.thisConversation
}
    

    //on clicks start
    
    //when user clicks add participants, move them to the participant controller so they can choose who to add
    @IBAction func onClickAddParticipants(_ sender: Any) {
        self.performSegue(withIdentifier: "addParticipantSegue" , sender: self) //pass data over to
    }
    
    
    //when the user clicks the send message button determine if there is a file attached or just a message and send based on that
    @IBAction func onClickSendMessage(_ sender: Any) {
        if(!file_attached){ //if file_attached is false then send a message
            sendMessage()
        }else{  //there is a file attached so send a file message instead
            sendFileMessage()
        }
        
    }
    
    //when the user clicks the x button, remove the file, remove the name, collapse both the x and the name
    @IBAction func onClickX(_ sender: Any) {
        
    }
    
    
    
    //when user clicks the add file button then deal with adding a file to the chat and setting file_attached to true
    @IBAction func onClickAttachFile(_ sender: Any) {
//        var attachment = AttachmentHandler()    //create an instance of the attachment handler class to allow user to chooose image/video/file/or take a picture
//        attachment.showAttachmentActionSheet(vc: self)

        
        //prompt them with the actions they have available
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        
        //if they choose an image, show the x button and replace the label text with the name of the file
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            
            let storageRef = self.baseStorageReference.reference()
            var childString = "conversationfiles/" + String(self.thisConversation["id"] as! String) + "/here1"
            var storageImageRef = storageRef.child(childString)
            self.imageByteArray = (image.jpegData(compressionQuality: 1.0)!) as NSData
            
            // Upload the file to the path storagePath
            let uploadTask = storageImageRef.putData(self.imageByteArray as! Data, metadata: nil) { (metadata, error) in
            }
            
            // Upload completed successfully
            uploadTask.observe(.success) { snapshot in
                print("success")
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
        
        
        //prompt the user to choose a file
//        let types = [kUTTypePDF as String, kUTTypeText as String, kUTTypeRTF as String, kUTTypeSpreadsheet as String]
//        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
//        documentPicker.delegate = self
//        documentPicker.modalPresentationStyle = .overCurrentContext
//        self.present(documentPicker, animated: true, completion: nil)
        
        //display the cancel button so they can cancel the file when attached
        
        //changee variable to true
    }
    
    
    
    //on clicks end
    
    
    
    
    // start of functions for picking a local file
//    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let myURL = urls.first else {
//            return
//        }
//        print("import result : \(myURL)")
//    }
//    
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        print("view was cancelled")
//        controller.dismiss(animated: true, completion: nil)
//    }
//

    // end of functions for picking a local file
    
    
    
    
    //send a file over the chat
    func sendFileMessage(){
        
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
//                    print("first data acquisition ")
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
        let lastMessage = self.messages[indexPath.row]["message_text"] as! String
        let lastMessageSenderID = self.messages[indexPath.row]["author_id"] as! String //the author of the last message that was sent
        var lastMessageAuthor = ""
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        
        //use ID to extract name of author
        let lastMessafeRef =  baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(lastMessageSenderID)
        lastMessafeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                lastMessageAuthor =  document.get("first_name") as! String //first name of last message author
                authorProfilePicLoc = "userimages/" + (document.get("id") as! String) + "/preview.jpg"

//                authorProfilePicLoc = document.get("profile_picture") as! String //location of profile pic in storage
                
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
