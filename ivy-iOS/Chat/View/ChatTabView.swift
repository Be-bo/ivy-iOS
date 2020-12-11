//
//  ChatTabView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct ChatTabView: View {
    
    var thisUserRepo : ThisUserRepo
    @ObservedObject var chatTabVM : ChatTabViewModel
    @State private var settingsPresented = false
    @State private var loadingWheelAnimating = true
    @State private var offset = CGSize.zero
    
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        chatTabVM = ChatTabViewModel(userID: thisUserRepo.user.id)
    }
    
    var body: some View {
        VStack {
            List{
                ForEach(chatTabVM.chatRoomVMs) { chatRoomVM in
                    ChatRoomItemView()
                    //WORKING HERE
                    //how to access corresponding lastMessage for the room?
                }
            }
        }
    }
}
