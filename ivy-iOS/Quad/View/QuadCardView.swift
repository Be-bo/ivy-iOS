//
//  QuadCardView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct QuadCardView: View {
    
    @ObservedObject var userVM: UserViewModel
    @State var selection : Int? = nil
    var thisUserRepo: ThisUserRepo
    
    
    var body: some View {
        ZStack {

            // MARK: Picture
            FirebaseCardImage(path: Utils.userProfileImagePath(userId: self.userVM.id))
            .onTapGesture {
                self.selection = 1
            }

            
            // MARK: User Info
            VStack(alignment: .leading) {

                Spacer()
                
                HStack {
                    
                    // User name
                    Button(action: {
                        self.selection = 1
                    }) {
                        Text(userVM.user.name).bold()
                    }
                    
                    // Chat Button
                    Button(action: {
                        self.selection = 2
                    }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AssetManager.ivyGreen)
                    }
                    
                    Spacer()
                }
  
                Text(userVM.user.degree ?? "").foregroundColor(.black)
            }
            .padding()
            .padding(.bottom, 40)
            .onTapGesture {
                self.selection = 1
            }
            
            // Go To User Profile
            NavigationLink(destination: UserProfileNavView(uid: userVM.id, thisUserRepo: thisUserRepo),
                           tag:1,
                           selection: self.$selection) { EmptyView()}
            
            // Create a new chatroom with user
            NavigationLink(
                destination: ChatRoomView(userID: self.userVM.id, thisUserRepo: thisUserRepo)
                    .navigationBarTitle("Message \(userVM.user.name)", displayMode: .inline),
                tag: 2, selection: self.$selection) {
                    EmptyView()
            }
        }
    }
}
