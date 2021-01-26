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



// MARK: Bugs
// thisUser not registered in new chatroom,
// Sending new message is weird...
// loading a message too many times???

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ChatRoomView: View {
    
    @ObservedObject var chatRoomVM : ChatRoomViewModel
    @ObservedObject var thisUserRepo : ThisUserRepo
    
    @State private var loadingWheelAnimating = true
    @State private var loadInProgress = false
    @State private var selection : Int? = nil

    
    
    // Existing chatrooms
    init(chatRoomVM: ChatRoomViewModel, thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        self.chatRoomVM = chatRoomVM
        chatRoomVM.fetchNextBatch() //Fetch more than just the first item
    }
    
    // New chatroom if not existing
    init(userID: String, thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        self.chatRoomVM = ChatRoomViewModel(chatroom: Chatroom(id1: thisUserRepo.user.id, id2: userID), userID: userID, thisUserID: thisUserRepo.user.id, thisUserName: thisUserRepo.user.name)
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
                
                TextField("A/a", text: $chatRoomVM.msgField)
                    .padding(.horizontal)
                    .frame(height: 45)  // Fixed height for Animation
                    .background(AssetManager.ivyLightGrey.opacity(0.6))
                    .clipShape(Capsule())
                
                // Send button
                if chatRoomVM.msgField != "" {
                    if (chatRoomVM.waitingToSend) {
                        LoadingSpinner()
                    }
                    else {
                        Button(action: {
                            self.loadInProgress = true
                            chatRoomVM.sendMessage(Message(author: thisUserRepo.user.id, text: chatRoomVM.msgField))
                        }){
                           Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width:45, height:45)
                            .background(AssetManager.ivyGreen)
                            .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(chatRoomVM.isEmpty() || chatRoomVM.waitingToSend)
                        
                    }
                }
            }
            .animation(.default)
            .padding()
            
            // Go To User Profile
            if let partner = chatRoomVM.partner {
                NavigationLink(destination: UserProfileNavView(uid: partner.user.id),
                               tag:1,
                               selection: self.$selection) { EmptyView()}
            }
        }
        .navigationBarTitle(Text(chatRoomVM.partner?.user.name ?? "ChatRoom"), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Text("Profile")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(AssetManager.ivyGreen)
                .onTapGesture {
                    if let _ = chatRoomVM.partner?.user.name {
                        self.selection = 1
                    }
                }
        })
        .onTapGesture { //hide keyboard when background tapped
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
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


