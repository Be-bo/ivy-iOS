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
    @Published var messagesLoaded = false
    var id = ""
    private var chatRoomRepo : ChatRoomRepo
    private var cancellables = Set<AnyCancellable>()
    
    
    init(chatroom: Chatroom, userID: String) {
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
        
        
        // Partner User
        chatRoomRepo.$partner.compactMap { user in
            UserViewModel(user: user)
        }
        .assign(to: \.partner, on: self)
        .store(in: &cancellables)
    }
    

    
    // Fetch next batch if not already loading
    func fetchNextBatch() {
        if (!chatRoomRepo.messagesLoading) {
            chatRoomRepo.loadMessages()
        }
    }

    // Send a Message
    func sendMessage(_ msg: Message) {
        chatRoomRepo.sendMessage(msg)
    }
}
