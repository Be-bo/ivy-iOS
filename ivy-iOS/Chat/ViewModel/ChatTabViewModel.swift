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
    @Published var chatroomsLoaded = false
    private var chatRepo : ChatRepo
    private var cancellables = Set<AnyCancellable>()
    
    
    init(userID: String) {
        self.chatRepo = ChatRepo(id: userID)
        
        // Chatroom
        chatRepo.$chatrooms.map { rooms in
            rooms.map { room in
                var userid : String
                if (room.members[0] == userID) {
                    userid = room.members[1]
                }
                else {
                    userid = room.members[0]
                }
                return ChatRoomViewModel(chatroom: room, userID: userid)
            }
        }
        .assign(to: \.chatRoomVMs, on: self)
        .store(in: &cancellables)
        
        // Loaded?
        chatRepo.$chatroomsLoaded
        .assign(to: \.chatroomsLoaded, on: self)
        .store(in: &cancellables)
    }
    
    // Fetch next batch if not already loading
    func fetchNextBatch() {
        if (!chatRepo.chatroomsLoading) {
            chatRepo.loadChatrooms()
        }
    }
}
