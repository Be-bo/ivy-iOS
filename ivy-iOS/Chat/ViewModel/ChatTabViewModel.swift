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
    
    
    init(thisUserID: String, thisUserName: String) {
        self.chatRepo = ChatRepo(id: thisUserID)
        
        // Chatroom
        chatRepo.$chatrooms.map { rooms in
            rooms.map { room in
                var userID : String
                if (room.members[0] == thisUserID && room.members.count > 1) {
                    userID = room.members[1]
                }
                else {
                    userID = room.members[0]
                }
                return ChatRoomViewModel(chatroom: room, userID: userID, thisUserID: thisUserID, thisUserName: thisUserName)
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
