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
    @State var selection : Int? = nil
    
    
    // MARK: INIT
    init(chatRoomVM: ChatRoomViewModel) {
        self.chatRoomVM = chatRoomVM
    }
    
    
    // MARK: BODY
    var body: some View {
        HStack {
            
            if ((chatRoomVM.partner?.user.id ?? "") != ""){
                FirebaseImage(
                    path: Utils.userPreviewImagePath(userId: chatRoomVM.partner!.user.id),
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: 40,
                    height: 40,
                    shape: RoundedRectangle(cornerRadius: 20)
                )
            }
            
            VStack (alignment: .leading) {
                
                Text(chatRoomVM.partner?.user.name ?? "ChatRoom")
                
                if (chatRoomVM.messagesVMs.count > 0) {
                    Text(chatRoomVM.messagesVMs[0].message.text)
                        .font(.system(size: 15))
                        .foregroundColor(AssetManager.ivyLightGrey)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
}
