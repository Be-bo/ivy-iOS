//
//  ChatRoomView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-24.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Citations:
//  https://medium.com/@michael.forrest.music/how-to-make-a-scrollview-or-list-in-swiftui-that-starts-from-the-bottom-b0c4a69beb0d
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ChatRoomView: View {
    
    @ObservedObject var chatRoomVM : ChatRoomViewModel
    var thisUserRepo = ThisUserRepo()
    
    @State private var loadingWheelAnimating = true
    @State var msgField = ""

    
    
    // Existing chatrooms
    init(chatRoomVM: ChatRoomViewModel) {
        self.chatRoomVM = chatRoomVM
        chatRoomVM.fetchNextBatch() //Fetch more than just the first item
    }
    
    // New chatroom
    init(userID: String) {
        self.chatRoomVM = ChatRoomViewModel(chatroom: Chatroom(id1: thisUserRepo.user.id, id2: userID), userID: userID)
    }
    
    
    var body: some View {
        VStack {
            
            // MARK: Messages list
            ScrollView(.vertical, showsIndicators: true){
                VStack {
                    ForEach(chatRoomVM.messagesVMs) { msgVM in
                        ChatMessageView(messageVM: msgVM, thisUserID: thisUserRepo.user.id)
                            .flippedUpsideDown()
                    }
                    
                    // Pagination: Fetch next batch
                    if !chatRoomVM.messagesLoaded {
                        HStack {
                            Spacer()
                            ActivityIndicator($loadingWheelAnimating)
                                .flippedUpsideDown()
                                .onAppear {
                                    self.chatRoomVM.fetchNextBatch()
                                }
                            Spacer()
                        }
                    }
                    
                    // No Chatrooms
                    if(chatRoomVM.messagesVMs.count < 1) {
                        Text("Send a Message!")
                            .font(.system(size: 25))
                            .foregroundColor(AssetManager.ivyLightGrey)
                            .multilineTextAlignment(.center)
                            .flippedUpsideDown()
                            .padding(30)
                    }
                }
                .padding()
            }
            .flippedUpsideDown()

            
            // MARK: Send message
            HStack(spacing: 15) {
                
                TextField("A/a", text: $msgField)
                    .padding(.horizontal)
                    .frame(height: 45)  // Fixed height for Animation
                    .background(AssetManager.ivyBackgroundGrey)
                    .clipShape(Capsule())
                
                // Send button
                if msgField != "" {
                    Button(action: {
                        chatRoomVM.sendMessage(Message(author: thisUserRepo.user.id, text: msgField))
                    }){
                       Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width:45, height:45)
                        .background(AssetManager.ivyGreen)
                        .clipShape(Circle())
                    }
                }
            }
            .animation(.default)
            .padding()
                
        }
        .navigationBarTitle(Text(chatRoomVM.partner?.user.name ?? "ChatRoom"), displayMode: .inline)
    }
}



// WACK helper --> iOS 14 solves this issue in ScrollView
struct FlippedUpsideDown: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
extension View {
    func flippedUpsideDown() -> some View {
        self.modifier(FlippedUpsideDown())
    }
}


