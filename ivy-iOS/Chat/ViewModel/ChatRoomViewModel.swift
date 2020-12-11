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
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(chatroom: Chatroom) {
        self.chatroom = chatroom
        
        $chatroom.compactMap { chatroom in
            chatroom.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
