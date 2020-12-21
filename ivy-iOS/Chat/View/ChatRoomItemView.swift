//
//  ChatRoomItemView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct ChatRoomItemView: View {
    
    @ObservedObject var chatRoomVM : ChatRoomViewModel
    @ObservedObject var lastMsgVM : MessageViewModel
    var thisUserRepo = ThisUserRepo()
    
    private var msgExists = true
    private var title = "Chatroom"
    
    
    // MARK: INIT
    init(thisUserRepo: ThisUserRepo, chatRoomVM: ChatRoomViewModel, lastMsgVM: MessageViewModel?) {
        self.thisUserRepo = thisUserRepo
        self.chatRoomVM = chatRoomVM
        
        if (lastMsgVM != nil) {
            self.lastMsgVM = lastMsgVM!
        } else {
            self.lastMsgVM = MessageViewModel(message: Message())
            self.msgExists = false
        }
        
        // Set Chatroom title
        let i = chatRoomVM.chatroom.members.firstIndex(of: thisUserRepo.user.id)
        if (i != nil){
            if (i! > 0) {
                self.title = chatRoomVM.chatroom.members[1]
            } else {
                self.title = chatRoomVM.chatroom.members[0]
            }
        }
        
    }
    
    
    // MARK: BODY
    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
    }
}
