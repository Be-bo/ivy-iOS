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
    
    @ObservedObject var thisUserRepo : ThisUserRepo
    @ObservedObject var chatTabVM : ChatTabViewModel
    @State private var settingsPresented = false
    @State private var loadingWheelAnimating = true
    @State private var offset = CGSize.zero
    @State var showingAlert = false
    @State var deleteIndexSet : IndexSet?
    
    
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        chatTabVM = ChatTabViewModel(thisUserID: thisUserRepo.user.id, thisUserName: thisUserRepo.user.name)
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
                
                // List of Chatrooms
                List(){
                    ForEach(chatTabVM.chatRoomVMs) { chatRoomVM in
                        NavigationLink(destination: ChatRoomView(chatRoomVM: chatRoomVM, thisUserRepo: thisUserRepo)) {
                            ChatRoomItemView(chatRoomVM: chatRoomVM)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        self.showingAlert = true
                        self.deleteIndexSet = indexSet
                    })
                    
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
                        .foregroundColor(AssetManager.ivyLightGrey.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    Spacer()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Delete Conversation?"), message: Text("This Chatroom will be permanently removed for you."), primaryButton: .destructive(Text("Delete")) {
                    if let indexSet = self.deleteIndexSet {
                        deleteChatrooms(at: indexSet)
                    }
                }, secondaryButton: .cancel())
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
