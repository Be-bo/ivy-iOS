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

class ChatRoom: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    
    // MARK: Variables and Constants
    
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
    var imagePicked: ((UIImage))?
    var filePicked: ((URL))?
    var first_launch = true                             //for auto scroll (so it only happens once and not every time the user scrolls)
    private var isJustFile = true                       //is just file will be set when its jsut a file, not image sent over
    var imageChosenToDownload:UIImage? = nil
    /// Creating UIDocumentInteractionController instance.
    let documentInteractionController = UIDocumentInteractionController()
    let screenSize: CGRect = UIScreen.main.bounds
    
    let sender = PushNotificationSender()

    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var messageCollectionView: UICollectionView!
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var xButton: UIButton!   //x button that gets shown when a file is attached
    @IBOutlet weak var fileNameLabel: UILabel!  //the label that will display the name of the file thats attached
    @IBOutlet weak var fileNameHeight: NSLayoutConstraint!
    @IBOutlet weak var xButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var msgFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileBtnHeightConstraint: NSLayoutConstraint!
    
    @IBAction func onClickSendMessage(_ sender: Any) { //when the user clicks the send message button determine if there is a file attached or just a message and send based on that
        if(!self.file_attached){ //if file_attached is false then send a message
            sendMessage()
        }else{  //there is a file attached so send a file message instead
            sendFileMessage()
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startListeningToChangesInThisConversation()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        hideKeyboardOnTapOutside()
        setUpKeyboardListeners()
        
        messageCollectionView.delegate = self
        messageCollectionView.dataSource = self
        messageCollectionView.register(UINib(nibName:"chatBubbleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chatBubbleCollectionViewCell")
        
//        configureTableView()
        xButton.isHidden = true //make sure the x button is hidden by default
        xButtonHeight.constant = 0
        fileNameHeight.constant = 0
    }
    
    private func setUpKeyboardListeners(){ //setup listeners for if they click on actions to show the keyboard, and when they click on button, to hide keyboard
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
    
    
    
    
    // MARK: Actions Related Functions
    
    @objc func showActions(){ //all the possible actions that a user can have on the conversation.
        if let isBaseConv = self.thisConversation["is_base_conversation"] as? Bool, let mutedBy = self.thisConversation["muted_by"] as? [String]{
            var isMuted = false
            
            let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
            actionSheet.view.tintColor = UIColor.ivyGreen
            
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            //        //if the conversation has been muted by atleast one person
            //        if(mutedBy.count > 0){
            //            if(mutedBy.contains(self.thisUserProfile["id"] as! String)){ //if you muted the conversation then add the option to unmute instead.
            //                isMuted = true
            //                actionSheet.addAction(UIAlertAction(title: "Unmute Conversation", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
            //            }else{  //the conversation hasn't been muted by anyone
            //                actionSheet.addAction(UIAlertAction(title: "Mute", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
            //            }
            //        }else{  //the conversation hasn't been muted by anyone
            //            actionSheet.addAction(UIAlertAction(title: "Mute", style: .default, handler: self.onClickMuteConversation(isMuted: isMuted)))
            //        }
            
            
            actionSheet.addAction(UIAlertAction(title: "Add Participants", style: .default, handler: self.onClickAddParticipants))
            
            //        actionSheet.addAction(UIAlertAction(title: "Leave Conversation", style: .default, handler: self.onClickLeaveConversation))  //TODO: implement this!!!
            
            actionSheet.addAction(UIAlertAction(title: "Report Conversation", style: .default, handler: self.onClickReportConversation))
            
            //if its a base conversation (1-1) then it  will be view member profile, if not then we can view ALL the members part of the conversation
            if(isBaseConv){
                actionSheet.addAction(UIAlertAction(title: "View User's Profile", style: .default, handler: self.onClickViewProfile))
            }else{
                actionSheet.addAction(UIAlertAction(title: "View Participants", style: .default, handler: self.onClickViewParticipants))
                actionSheet.addAction(UIAlertAction(title: "Change Group Name", style: .default, handler: self.onClickChangeGroupName))
            }
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
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
    
    func onClickChangeGroupName(alert: UIAlertAction!) { //when they click change group name send them here
        self.performSegue(withIdentifier: "chatToChangeGroupName" , sender: self) //pass data over to
    }
    
    func onClickLeaveConversation(alert: UIAlertAction!) {
        //TODO: implement this user leaving the current conversation
    }
    
    func onClickAddParticipants(alert: UIAlertAction!) { //participant controller segue to allow them to add more people to the chat
        
        //if its a request, don't let them add participant's
        if let isRequest = self.thisConversation["is_request"] as? Bool, isRequest {
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You cannot add any participants to a request conversation. Either accept the request or wait for the other user to accept it.", context: self)
        }else{
            self.performSegue(withIdentifier: "addParticipantSegue" , sender: self) //pass data over to
        }
        
   
    }
    
    func onClickViewParticipants(alert: UIAlertAction!){ //when they click "view participants"
        self.performSegue(withIdentifier: "viewParticipantsSegue" , sender: self) //pass data over to
    }
    
    func onClickViewProfile(alert: UIAlertAction!) { //when its a base conversation and they click on the profile to view
        self.otherId = getOtherParticipant(conversation: self.thisConversation, returnName: false)   //extract other participant id
        if (self.otherId != ""){ //if there is actually someone part of the conversation
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
        }
    }
    
    func getOtherParticipant(conversation: Dictionary<String,Any>, returnName:Bool) -> String { //helper funtion for view profile that will retrieve the other participant that is active in this conversation
        var returnVal = ""
        if let participants = conversation["participants"] as? [String], let participantNames = conversation["participant_names"] as? [String], let thisUserId = thisUserProfile["id"] as? String{
            var otherParticipantId = ""
            var otherParticipantName = ""
            for (index, participant) in participants.enumerated() {
                if !(participant == thisUserId){
                    otherParticipantId = participant
                    otherParticipantName = participantNames[index]
                    if(returnName) {returnVal = otherParticipantName}
                    else{returnVal = otherParticipantId}
                }
            }
        }
        return returnVal
    }
    
    func onClickMuteConversation(isMuted:Bool) -> (_ alertAction:UIAlertAction) -> () { //when the user clicks to mute the conversation or to unmute the conversation
        var thisUserProfileID = [String]()   //arraylist of strings
        if let thisUserId = thisUserProfile["id"] as? String{
            thisUserProfileID.append(thisUserId)
        }
        return { alertAction in
            if (isMuted){
                if let convId = self.thisConversation["id"] as? String{
                    self.baseDatabaseReference.collection("conversations").document(convId).updateData(["muted_by": FieldValue.arrayRemove(thisUserProfileID) ])
                }
            }else{
                if let convId = self.thisConversation["id"] as? String{
                    self.baseDatabaseReference.collection("conversations").document(convId).updateData(["muted_by": FieldValue.arrayUnion(thisUserProfileID )])
                }
            }
        }
    }
    
    func onClickReportConversation(alert: UIAlertAction!) { //when the user clicks to mute the conversation or to unmute the conversation
        var report = Dictionary<String, Any>()
        if let thisId = self.thisUserProfile["id"] as? String, let convId = self.thisConversation["id"] as? String{
            report["reportee"] = thisId
                report["report_type"] = "conversation"
            report["target"] =  convId //this current conversation id
                report["time"] = Date().millisecondsSince1970
            let reportId = self.baseDatabaseReference.collection("reports").document().documentID   //create unique id for this document
            report["id"] = reportId
            self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: thisId).whereField("target", isEqualTo: convId).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if(!querySnapshot!.isEmpty){
                        
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You have already reported this conversation.", context: self)
                    }else{
                        self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Success", infoText: "You've successfully reported the conversation", context: self)
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: File Attachment Related Functions
    
    @IBAction func onClickX(_ sender: Any) { //when the user clicks the x button, remove the file, remove the name, collapse both the x and the name
        self.fileNameLabel.text = nil
        self.fileNameLabel.isHidden = true
        self.fileNameHeight.constant = 0
        self.xButton.isHidden = true
        self.xButtonHeight.constant = 0
        self.file_attached = false
        //reset the image and file picked
        self.imagePicked = nil
        self.filePicked = nil
    }
    
    @IBAction func onClickAttachFile(_ sender: Any) { //when user clicks the add file button then deal with adding a file to the chat and setting file_attached to true
        // ---------------------------------------------- OPTION PROMPTING FOR FILE UPLOADING ----------------------------------------------
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        // ---------------------------------------------- IMAGE CHOOSING ----------------------------------------------
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            self.file_attached = true
            self.isJustFile = true
            
            //Add the image name to the chat so they know what they just attached
            self.fileNameLabel.text = image.accessibilityIdentifier ?? "Photo.png"
            
            self.fileNameLabel.isHidden = false
            self.fileNameHeight.constant = 35
            
            //present the x that removes the image & name if clicked on
            self.xButton.isHidden = false
            self.xButtonHeight.constant = 35
            //set the image picked to be the one chosen by the user so that we can easily access it later
            self.imagePicked = image
            self.filePicked = nil   //clear file picked
        }
        // ---------------------------------------------- IMAGE CHOOSING ----------------------------------------------

        
        // ---------------------------------------------- FILE CHOOSING ----------------------------------------------

        AttachmentHandler.shared.filePickedBlock = { (url) in
            
            //limit file size to < 5mb
            if((url.fileSize / 1000) < 5000 ){
                self.file_attached = true
                self.isJustFile = false
                
                //Add the image name to the chat so they know what they just attached
                self.fileNameLabel.text = url.lastPathComponent
                self.fileNameLabel.isHidden = false
                
                //present the x that removes the image & name if clicked on
                self.xButton.isHidden = false
                
                //set the image picked to be the one chosen by the user so that we can easily access it later
                self.filePicked = url   //url of where the path is on the device
                
                self.imagePicked = nil //clear image picked incase its not empty
            }else{
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "Please limit the file size to less than 5MB", context: self)
            }
            
            
            
        }
        // ---------------------------------------------- FILE CHOOSING ----------------------------------------------

    }
    

    
    
    
    
    
    
    // MARK: Sending Message Functions
    
    func sendFileMessage(){ //send a file over the chat. differentiate b/w image or regular files (pdf's,word docs, etc.)
        let storageRef = self.baseStorageReference.reference()
        var filePath = ""
        var byteArray:NSData? =  nil
        var metadata = StorageMetadata()    //decided whether file is image/jpeg or w.e other type
        var uploadTask: StorageUploadTask   //differing upload tasks

        if let convId = self.thisConversation["id"] as? String, let thisUserId = self.thisUserProfile["id"] as? String{
            //if image not nill then user self.image, else use file since that must be ethe picked one
            if ( self.imagePicked != nil ){
                metadata.contentType = "image/png" // Create the file metadata TODO: decide if this should be nil and find out how to let firestore decide what content type it should be
                self.imagePicked!.accessibilityIdentifier = self.imagePicked?.accessibilityIdentifier ?? "Photo.png"
                filePath = "conversationfiles/" + String(convId) + "/" + self.imagePicked!.accessibilityIdentifier!  //path of where the files shared for this particular conversation saved at
//                byteArray = (self.imagePicked!.jpegData(compressionQuality: 1.0)!) as NSData  //convert to jpeg
                byteArray = (self.imagePicked!.jpegData(compressionQuality: 0.25)!) as NSData  //convert to jpeg

                self.fileNameLabel.text = nil //reset variables
                self.xButton.isHidden = true
                self.xButtonHeight.constant = 0
                self.file_attached = false
                self.fileNameLabel.isHidden = true
                self.fileNameHeight.constant = 0
            }else{
                //TODO deal with the file byte array and path/what not
                filePath = "conversationfiles/" + String(convId) + "/" + self.filePicked!.lastPathComponent  //path of where the files shared for this particular conversation saved at
                self.fileNameLabel.text = nil //reset variables
                self.xButton.isHidden = true
                self.xButtonHeight.constant = 0
                self.file_attached = false
                self.fileNameLabel.isHidden = true
                self.fileNameHeight.constant = 0
            }
            
            let storageLocRef = storageRef.child(filePath) //storeageImageRef now points to the correctspot that this should be save in
            var message = Dictionary<String, Any>()
            message["author_first_name"] = self.thisUserProfile["first_name"]
            message["author_last_name"] = self.thisUserProfile["last_name"]
            message["author_id"] = thisUserId
            message["conversation_id"] = convId
            message["creation_time"] =  Date().millisecondsSince1970   //millis
            
            
            if let messageText = messageTextField.text, messageText.count < 1{
                message["message_text"] =  "Sent a file:"
            }else{
                message["message_text"] =  messageTextField.text
            }
            
            
            message["is_text_only"] = false
            message["file_reference"] = filePath
            let ext = PublicStaticMethodsAndData.getFileExtensionFromPath(filePath: filePath)
            if(ext == "jpg" || ext == "jpeg" || ext == "png"){
                let uiImg = UIImage(data: byteArray as! Data)
                message["img_width"] = uiImg?.size.width
                message["img_height"] = uiImg?.size.height
            }else{
                message["img_width"] = 0
                message["img_height"] = 0
            }
            message["id"] =  NSUUID().uuidString
            
            self.updatePendingMessagesForParticipants()
            
            //different upload task based on if its a file or if its an image
            if ( self.imagePicked != nil ){
                uploadTask = storageLocRef.putData(byteArray! as Data, metadata: metadata) { (metadata, error) in
                }
            }else{
                uploadTask = storageLocRef.putFile(from: self.filePicked!, metadata: nil)
            }
            
            // Upload completed successfully
            uploadTask.observe(.success) { snapshot in
                self.messageTextField.text = ""
                self.updateLastSeenMessage()    //when a new message is sent we want to make sure the last message count is accurate if they are
                
                
                //update all the data to match accordingly
                self.baseDatabaseReference.collection("conversations").document(convId).collection("messages").document(message["id"] as! String).setData(message)
                self.baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message": message["message_text"] as! String])
                self.baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_author": message["author_id"] as! String])
                self.baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_millis": message["creation_time"] as! Int64  ])
                self.baseDatabaseReference.collection("conversations").document(convId).updateData(["message_count": self.messages.count + 1])
                
                self.sendNotification(message:message)
                
                //update last message count for this user
                let thisUserPos = self.locateUser(id: thisUserId) //get the position of the user in the array of participants to modify
                if (thisUserPos != -1) {
                    var lastMsgCounts = self.thisConversation["last_message_counts"] as? [CLong]
                    if(lastMsgCounts != nil) {
                        lastMsgCounts![thisUserPos] = self.messages.count + 1
                        self.baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_counts": lastMsgCounts])
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
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "The file you're trying to upload doesn't exist.", context: self)
                        break
                    case .unauthorized:
                        print("User doesn't have permission to access file")
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "You don't have permission to access the file you're trying to upload.", context: self)
                        break
                    case .cancelled:
                        print("User canceled the upload")
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "Upload cancelled.", context: self)
                        break
                    case .unknown:
                        print("unknown error")
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "An unknown error occurred.", context: self)
                        break
                    default:
                        print("retry the upload here if it fails")
                        break
                    }
                }
            }
        }
    }
    
    func sendMessage() { //actually sends the message to the conversation they are clicked on
        let inputMessage = messageTextField.text //extract the text field input
        if(inputMessage != ""), let thisUserId = self.thisUserProfile["id"] as? String, let convId = self.thisConversation["id"] as? String{ //if not empty
            messageTextField.text = "" //reset the message field to be empty
            var message = Dictionary<String, Any>()
            if (!thisUserProfile.isEmpty){  //make sure there is a user profile that exists
                message["author_first_name"] = self.thisUserProfile["first_name"]
                message["author_last_name"] = self.thisUserProfile["last_name"]
                message["author_id"] = thisUserId
                message["conversation_id"] = convId
                message["creation_time"] =  Date().millisecondsSince1970   //seconds * 1000 = milliseconds
                message["message_text"] = inputMessage
                message["is_text_only"] = true
                message["file_reference"] = ""
                message["id"] =  NSUUID().uuidString
                
                self.updatePendingMessagesForParticipants()
                
                baseDatabaseReference.collection("conversations").document(convId).collection("messages").document(message["id"] as! String).setData(message)
                baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_millis": message["creation_time"] as! Int64  ])
                baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message": message["message_text"] as! String])
                baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_author": message["author_id"] as! String])
                baseDatabaseReference.collection("conversations").document(convId).updateData(["message_count": self.messages.count + 1])
                
                let thisUserPos = locateUser(id: thisUserId) //get the position of the user in the array of participants to modify
                if (thisUserPos != -1) {
                    var lastMsgCounts = thisConversation["last_message_counts"] as? [CLong]
                    if(lastMsgCounts != nil) {
                        lastMsgCounts![thisUserPos] = self.messages.count + 1
                        self.baseDatabaseReference.collection("conversations").document(convId).updateData(["last_message_counts": lastMsgCounts])
                    }
                }
                
                self.sendNotification(message:message)
                self.updateLastSeenMessage()    //when a new message is sent we want to make sure the last message count is accurate if they are
                //TODO: decide if need to compensatefor listener bug here (Check android for code)
            }
        }
    }
    
    private func updatePendingMessagesForParticipants(){
        if let participants = thisConversation["participants"] as? [String], let thisUserId = thisUserProfile["id"] as? String, let uniDomain = thisUserProfile["uni_domain"] as? String{
            for i in 0..<participants.count{
                let currentId = participants[i]
                if(currentId != thisUserId){
                    var toMerge = Dictionary<String, Any>()
                    toMerge["pending_messages"] = true
                    baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(currentId).setData(toMerge, merge: true)
                }
            }
        }
    }
    
    
    //NOTIFICATION SENDING
    private func sendNotification(message:Dictionary<String,Any>) {
        //if ifs a base conversation vs if its not a base conversation
        if let booleanIsBaseConv = self.thisConversation["is_base_conversation"] as? Bool {
            if let authorFirstName = message["author_first_name"] as? String, let authorLastName = message["author_last_name"] as? String, let messageText = message["message_text"] as? String, let uniDomain = thisUserProfile["uni_domain"] as? String, let conversationID = self.thisConversation["id"] as? String {
                    if (booleanIsBaseConv == true){
                        self.otherId = getOtherParticipant(conversation: self.thisConversation, returnName: false)   //extract other participant id
                        if (self.otherId != ""){ //if there is actually someone part of the conversation
                            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(self.otherId).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let user = document.data()
                                    //user will exist hhere since document data has to  exist here
                                    if let usersMessagingToken = user!["messaging_token"] as? String {
                                        print("BASE CONVO  other user messaging token: ", usersMessagingToken)
                                        //actually notify the user of that device
                                        print("conversation id: ", conversationID)
                                        self.sender.sendPushNotification(to: usersMessagingToken, title: authorFirstName + " " + authorLastName, body: messageText, conversationID: conversationID)
                                        //else title is just name of author for base conversation
                                    }
                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                    }else if (booleanIsBaseConv == false){ //if group convo then title is name of the convo
                        //extract all the id's of the users
                        if let convName = self.thisConversation["name"] as? String, let participantIDs = self.thisConversation["participants"] as? [String], let thisUserId = thisUserProfile["id"] as? String {
                            //for every participant either then yourself in this conversation, get their FCM token, then send a message to that token.
                            for i in 0..<participantIDs.count{
                                var currentId = participantIDs[i]
                                if(currentId != thisUserId){
                                    self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(currentId).getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            let user = document.data()
                                            if let usersMessagingToken = user!["messaging_token"] as? String {
                                                print("conversation id: ", conversationID)
                                                self.sender.sendPushNotification(to: usersMessagingToken, title: convName , body: authorFirstName + " : " + messageText, conversationID:conversationID)
                                            }
                                        } else {
                                            print("Document does not exist")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquistion Functions
    
    func startListeningToChangesInThisConversation() { //listen and retrun the up to date conversation object
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
    
    func startRetrievingMessages() { //used to get the messages that are present within the current conversation
        if let convId = self.thisConversation["id"] as? String{
            baseDatabaseReference.collection("conversations").document(convId).collection("messages").order(by: "creation_time", descending: false).addSnapshotListener(){ (querySnapshot, err) in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(err!)")
                    return
                }
                //FOR EACH individual conversation the user has, when a message is added
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        self.messages.append(diff.document.data())  //append the message document to the messages array
                        
                        //                    self.messageCollectionView.reloadData()
                        // Update Table Data
                        //                    self.messageCollectionView.beginUpdates()
                        self.updateLastSeenMessage()    //when a new message is added we want to make sure the last message count is accurate if they are sitting in the chat
                        
                        //use reload data instead of insert cause that fucks it up sometimes
                        self.messageCollectionView.reloadData()

                        
                        
                    }
                }
                self.messageCollectionView.reloadData()
                
                let lastItemIndex = self.messageCollectionView.numberOfItems(inSection: 0) - 1
                let indexPath:IndexPath = IndexPath(item: lastItemIndex, section: 0)
                self.messageCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                

            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: CollectionView Related Functions

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatBubbleCollectionViewCell", for: indexPath) as! chatBubbleCollectionViewCell
        
        self.updateLastSeenMessage()    //when a new message is added we want to make sure the last message count is accurate if they are
        var authorProfilePicLoc = ""    //storage lcoation the profile pic is at
        
        
        let lastMessageAuthor =  self.messages[indexPath.row]["author_first_name"] as? String ?? "" //first name of last message author
        let lastMessage = self.messages[indexPath.row]["message_text"] as? String
        authorProfilePicLoc = "userimages/" + String(self.messages[indexPath.row]["author_id"] as? String ?? "") + "/preview.jpg"
        
        // Create a storage reference from our storage service
        let storageRef = self.baseStorageReference.reference()
        let storageImageRef = storageRef.child(authorProfilePicLoc)
        
        storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in //get author's image and decide whether to show it or not (if the sender is this user then don't show it and adjust the layout)
            if let error = error {
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "Maximum download size is 5MB", context: self)
                print("error", error)
            } else {
                cell.messageLabel.text = lastMessage
                if let authorId = self.messages[indexPath.row]["author_id"] as? String, let thisUserId = self.thisUserProfile["id"] as? String, thisUserId == authorId{
                    cell.imageView.isHidden = true
                    cell.messageContainer.backgroundColor = UIColor.ivyGreen
                }else{
                    cell.imageView.isHidden = false
                    cell.messageContainer.backgroundColor = UIColor.ivyLightGrey
                    cell.imageView.image  = UIImage(data: data!)
                }
            }
        }
        
        
        if let isTxtOnly = self.messages[indexPath.item]["is_text_only"] as? Bool{ //adjust the cell based on whether the message has a file attached to it or not
            if(isTxtOnly){ //text only
                cell.fileIconHeight.constant = 0
                cell.fileNameHeight.constant = 0
                cell.downloadButtonHeight.constant = 0
                cell.downloadButtonHeight.constant = 0
                cell.photoImageHeight.constant = 0
                cell.photoImageView.isHidden = true
            }else{ //contains a file
                
                if let fileRef = self.messages[indexPath.item]["file_reference"] as? String { //get the file
                    let fileName = fileRef.components(separatedBy: "/").last!
//                    let fileExt = PublicStaticMethodsAndData.getFileExtensionFromPath(filePath: fileRef)
                    
                    let storageImageRef = self.baseStorageReference.reference().child(fileRef)
                    storageImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            
                            if let imgWidth = self.messages[indexPath.item]["img_width"] as? CGFloat, let imgHeight = self.messages[indexPath.item]["img_height"] as? CGFloat, imgWidth > 0, imgHeight > 0{ //if the file is an image and we have it's dimens
                                cell.fileIconHeight.constant = 0
                                cell.downloadButtonHeight.constant = 0
                                cell.photoImageView.isHidden = false
                                cell.fileNameHeight.constant = 0
                                cell.photoImageView.image = UIImage(data:data!)
                                
                            }else{ //the file is either not an image or we don't have it's dimens in which case show it as a standard file
                                cell.fileIconHeight.constant = 30
                                cell.downloadButtonHeight.constant = 30
                                cell.photoImageHeight.constant = 0
                                cell.photoImageView.isHidden = true
                                cell.fileNameHeight.constant = 30
                                cell.fileNameLabel.text = fileName
                            }
                        }
                    }
                }
            }
        }
        
        cell.setUp(msg: self.messages[indexPath.item], rulingVC: self) //set up the actual cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = self.messages[indexPath.item]["message_text"] as? String, let isTxtOnly = self.messages[indexPath.item]["is_text_only"] as? Bool{
//            let size = CGSize(width: screenSize.size.width-90, height: 0)
//            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
////            let font = UIFont.systemFont(ofSize: 25)
//            let font = UIFont.init(name: "Cordia New", size: 33)
//            let attributes = [NSAttributedString.Key.font: font]
//            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: attributes, context: nil)
//            print("abzlabelwidth: ", screenSize.width-90)
//            print("abzheight: ",estimatedFrame.height)
//            print("abzwidth: ",estimatedFrame.width)
            var heightForImage = CGFloat(0)
            
            let estimatedHeight = messageText.height(withConstrainedWidth: screenSize.width-90, font: UIFont.init(name: "Cordia New", size: 25)!) //by trial and error we know that with these values a single line has a height of 29
            
            if let imgHeight = self.messages[indexPath.item]["img_height"] as? CGFloat, let imgWidth = self.messages[indexPath.item]["img_width"] as? CGFloat, imgHeight>0, imgWidth>0{ //if the message contains an image and its dimens
                let imgViewWidth = screenSize.width - 90 //screen width - 50 for profile preview img and then 32 for 4x8 margins, see chatBubbleCollectionViewCell for details
                heightForImage = PublicStaticMethodsAndData.getHeightForShrunkenWidth(imgWidth: imgWidth, imgHeight: imgHeight, targetWidth: imgViewWidth)
            }
            
            if(estimatedHeight < 40){ //a check in case the message label is too small in terms of height (the container would get cut off) -> set a minimum height to it that we tested doesn't cut anything off
                if(isTxtOnly){ //text only
                    return CGSize(width: view.frame.width, height: 70)
                }else if(!isTxtOnly && heightForImage <= 0){ //contains a file that's not an image
                    return CGSize(width: view.frame.width, height: 100)
                }else{ //contains a file that is an image
                    return CGSize(width: view.frame.width, height: 70 + heightForImage)
                }
                
            }else{//if the message label is estimated to be longer then use the estimate, add the margins (again see chatBubbleCollectionViewCell for details)
                if(isTxtOnly){ //text only
                   return CGSize(width: view.frame.width, height: estimatedHeight + 41)//the constrained initial height for the label is 29 (also = a single line height for the estimated text box size) and the default cell size is 70 so 41 is all the constraints in between
                }else if (!isTxtOnly && heightForImage <= 0){ //contains a file that' not an image
                    return CGSize(width: view.frame.width, height: estimatedHeight + 71) //extra 30 is for the file layer (icon, file name and download button)
                }else{ //contains a file that is an image
                    return CGSize(width: view.frame.width, height: estimatedHeight + 41 + heightForImage)
                }
            }
        }
        return CGSize(width: view.frame.width, height: 70)
    }
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    // MARK: File Sharing Related Functions
    
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "YourAppName-\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    
    func showSavedPdf(url:String, fileName:String) {
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).pdf") {
                        // its your file! do what you want with it!
                        
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
    }
    
    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("YourAppName-\(fileName).pdf") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }
    


    
    
    
    
    
    
    
    
    
    
    // MARK: Support Methods
    
    func locateUser(id: String) -> Int { // used to located the index of the conversation from the activeChats array
        var position = 0
        if let participants = self.thisConversation["participants"] as? [String]{
            for (index, chat) in participants.enumerated(){    //for every chat the user is part of
                if(id == chat){  //if the chat has the same id as the modifiedID passed in
                    position = index    //now I have the correct index corresponding to this specific modified chat from all the chats
                }
            }
        }
        return position
    }
    
    func updateLastSeenMessage() { //update the last seen message count for this user for this conversations but only once we've loaded all its messages

        if let msgCount = self.thisConversation["message_count"] as? CLong, self.messages.count >= msgCount, var counts = self.thisConversation["last_message_counts"] as? [CLong], let participants = self.thisConversation["participants"] as? [String], let convId = self.thisConversation["id"] as? String{    //if we have more messages then the amount thats been seen
            
            //make sure we actually retrieved the data
            if(participants != nil && counts != nil){
                for (index, participant) in participants.enumerated(){    //for every chat the user is part of
                    if(self.thisUserProfile["id"] as? String == participant){  //if the chat has the same id as the modifiedID passed in
                        counts[index] = (self.messages.count)
                        //update the array in the db to contain the correct amount of messages now seen by this user
                        self.baseDatabaseReference.collection("conversations").document(convId).updateData([
                            "last_message_counts": counts,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Update last seen message document successfully updated")
                            }
                        }
                        break
                    }
                }
                
            }
        }
    }
}








// MARK: Extensions

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UICollectionView {
    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
    }
    
    func scrollToLastUnanimated() {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: false)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

