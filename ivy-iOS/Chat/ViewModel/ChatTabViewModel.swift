//
//  ChatTabViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class ChatTabViewModel: ObservableObject {
    
    @Published var chatRoomVMs = [ChatRoomViewModel]()
    @Published var lastMsgVMs = [MessageViewModel?]()
    @Published var chatroomsLoaded = false
    private var chatRepo : ChatRepo
    private var cancellables = Set<AnyCancellable>()
    
    
    init(userID: String) {
        self.chatRepo = ChatRepo(id: userID)
        
        // Chatroom
        chatRepo.$chatrooms.map { rooms in
            rooms.map { room in
                ChatRoomViewModel(chatroom: room)
            }
        }
        .assign(to: \.chatRoomVMs, on: self)
        .store(in: &cancellables)
        
        // Last Message
        chatRepo.$lastMessages.map { msgs in
            msgs.map { msg -> MessageViewModel? in
                if msg == nil {
                    return nil
                }
                return MessageViewModel(message: msg!)
            }
        }
        .assign(to: \.lastMsgVMs, on: self)
        .store(in: &cancellables)
    }
    
    // Fetch next batch if not already loading
    func fetchNextBatch() {
        if (!chatRepo.chatroomsLoading) {
            chatRepo.loadChatrooms()
        }
    }
}
