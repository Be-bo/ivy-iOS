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
    
    var thisUserRepo : ThisUserRepo
    @ObservedObject var chatTabVM : ChatTabViewModel
    @State private var settingsPresented = false
    @State private var loadingWheelAnimating = true
    @State private var offset = CGSize.zero
    
    
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        chatTabVM = ChatTabViewModel(thisUserID: thisUserRepo.user.id)
    }
    
    
    func deleteChatrooms(at offsets: IndexSet) {
        for i in offsets {
            chatTabVM.chatRoomVMs[i].deleteChatroom()
        }
    }
    
    
    // MARK: BODY
    var body: some View {
        
        NavigationView {
            
            VStack {
                // No Chatrooms
                if(chatTabVM.chatRoomVMs.count < 1) {
                    Text("No Conversations Available.")
                        .font(.system(size: 25))
                        .foregroundColor(AssetManager.ivyLightGrey.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    Spacer()
                }
                else {
                    // List of Chatrooms
                    List(){
                        ForEach(chatTabVM.chatRoomVMs) { chatRoomVM in
                            NavigationLink(destination: ChatRoomView(chatRoomVM: chatRoomVM, thisUserID: thisUserRepo.user.id)) {
                                ChatRoomItemView(
                                    thisUserRepo: thisUserRepo,
                                    chatRoomVM: chatRoomVM
                                )
                            }
                        }
                        .onDelete(perform: deleteChatrooms)
                        
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
                ,trailing:
                    EditButton().foregroundColor(AssetManager.ivyGreen)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
