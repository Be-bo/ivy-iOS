//
//  ChatTabView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ChatTabView: View {
    
    var thisUserRepo = ThisUserRepo()
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
            List(){
                ForEach(chatTabVM.chatRoomVMs) { chatRoomVM in
                        ChatRoomItemView(
                            thisUserRepo: thisUserRepo,
                            chatRoomVM: chatRoomVM,
                            lastMsgVM: nil
                        )
                }
                
                // Pagination: Fetch next batch
                if !chatTabVM.chatroomsLoaded {
                    HStack {
                        Spacer()
                        ActivityIndicator($loadingWheelAnimating)
                            .onAppear {
                                self.chatTabVM.fetchNextBatch()
                            }
                        Spacer()
                    }
                }
            }
            
            // No Chatrooms
            if(chatTabVM.chatRoomVMs.count < 1) {
                Text("No Conversations Available.")
                    .font(.system(size: 25))
                    .foregroundColor(AssetManager.ivyLightGrey)
                    .multilineTextAlignment(.center)
                    .padding(30)
            }
        }
        
        // MARK: Nav Bar
        .navigationBarItems(
            leading:
                HStack {
                    Button(action: {
                        self.settingsPresented.toggle()
                    }) {
                        Image(systemName: "gear").font(.system(size: 25))
                            .sheet(isPresented: $settingsPresented){
                                SettingsView(thisUserRepo: self.thisUserRepo)
                        }
                    }
                    
                    FirebaseImage(
                        path: Utils.uniLogoPath(),
                        placeholder: AssetManager.uniLogoPlaceholder,
                        width: 40,
                        height: 40,
                        shape: RoundedRectangle(cornerRadius: 0)
                    )
                    .padding(.leading, (UIScreen.screenWidth/2 - 75))
                    
                }.padding(.leading, 0)
        )
    }
}
