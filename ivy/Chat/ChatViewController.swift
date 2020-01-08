//
//  ChatViewController.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-01-07.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore
//import SDWebImage

class ChatViewController: MessagesViewController, MessagesDataSource, InputBarAccessoryViewDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate{
  
    var messages: [Message] = [] //of type messageType for msgKit
    private var thisUserProfile = Dictionary<String, Any>() //this user profile passed through the segue from the conversation view controller

    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        onLoad()
    }
    

    //setup messageKit UI
    func onLoad() {
        messagesCollectionView.messagesDataSource = self as? MessagesDataSource
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    //message bar at the bottom
    func buildMessageInputBar() {
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = UIImage(named: "send_message")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
    }
    


    
    
    // MARK: messagesDataSource protocol stubs Related Functions
    func currentSender() -> SenderType {
        if let firstName = thisUserProfile["first_name"] as? String,
        let lastName = thisUserProfile["last_name"] as? String {
            return Sender(senderId: firstName, displayName: lastName)
        }
        else{
            return Sender(senderId: "firstName", displayName: "lastName")
        }
    }


    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messages.count
    }




}
    
    
    

    
    
