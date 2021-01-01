//
//  ChatRoomViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine


class ChatRoomViewModel: ObservableObject, Identifiable {
    
    @Published var chatroom: Chatroom
    @Published var partner : UserViewModel?
    @Published var messagesVMs = [MessageViewModel]()
    @Published var msgField = ""
    @Published var messagesLoaded = false
    @Published var waitingToSend = false
    @Published var sentMsg = false {
        didSet {
            self.msgField = ""
        }
    }
    var id = ""
    private var chatRoomRepo : ChatRoomRepo
    private var cancellables = Set<AnyCancellable>()
    private var thisUserID : String
    private var userID : String
    
    
    init(chatroom: Chatroom, userID: String, thisUserID: String) {
        self.thisUserID = thisUserID
        self.userID = userID
        self.chatroom = chatroom
        self.chatRoomRepo = ChatRoomRepo(chatID: chatroom.id, userID: userID)
        
        // ID
        $chatroom.compactMap { chatroom in
            chatroom.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
        
        
        // Messages
        chatRoomRepo.$messages.map { msgs in
            msgs.map { msg in
                MessageViewModel(message: msg)
            }
        }
        .assign(to: \.messagesVMs, on: self)
        .store(in: &cancellables)
        
        // Loaded?
        chatRoomRepo.$messagesLoaded
        .assign(to: \.messagesLoaded, on: self)
        .store(in: &cancellables)
        
        // Sending in progress??
        chatRoomRepo.$waitingToSend
        .assign(to: \.waitingToSend, on: self)
        .store(in: &cancellables)
        
        chatRoomRepo.$sentMsg
        .assign(to: \.sentMsg, on: self)
        .store(in: &cancellables)
        
        
        // Partner User
        chatRoomRepo.$partner.compactMap { user in
            UserViewModel(user: user)
        }
        .assign(to: \.partner, on: self)
        .store(in: &cancellables)
    }
    

    func isEmpty() -> Bool {
        return msgField.isEmpty
    }
    
    // Fetch next batch if not already loading
    func fetchNextBatch() {
        if (!chatRoomRepo.messagesLoading) {
            chatRoomRepo.loadMessages()
        }
    }

    // Send a Message
    func sendMessage(_ msg: Message) {
        if messagesVMs.count > 0 { // Not a new chatroom
            chatRoomRepo.sendMessage(msg)
        }
        else { // Sending a message to a new chatroom
            chatRoomRepo.saveChatroom(room: chatroom, msg: msg, thisUserID: thisUserID, userID: userID)
        }
    }
}
