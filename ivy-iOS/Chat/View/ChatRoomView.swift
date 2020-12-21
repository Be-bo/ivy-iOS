//
//  ChatRoomView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct ChatRoomView: View {
    
    @ObservedObject var chatRoomVM : ChatRoomViewModel
    var thisUserRepo = ThisUserRepo()
    
    
    // Existing chatrooms
    init(chatRoomVM: ChatRoomViewModel) {
        self.chatRoomVM = chatRoomVM
    }
    
    // New chatroom
    init(userID: String) {
        self.chatRoomVM = ChatRoomViewModel(chatroom: Chatroom(id1: thisUserRepo.user.id, id2: userID), userID: userID)
    }
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            VStack {
                Text("Hello!")
            }
        }
    }
}
