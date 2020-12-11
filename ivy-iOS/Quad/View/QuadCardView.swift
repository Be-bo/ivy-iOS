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
    
    
    var body: some View {
        ZStack {

            // MARK: Picture
            FirebaseCardImage(path: Utils.userProfileImagePath(userId: self.userVM.id))

            
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
  
                Text(userVM.user.degree ?? "")
            }
            .padding()
            .padding(.bottom, 40)
            .background(LinearGradient(
                            gradient: SwiftUI.Gradient(colors: [Color.white.opacity(0), .white]),
                            startPoint: .center,
                            endPoint: .bottom))
            .onTapGesture {
                self.selection = 1
            }
            
            // Go To User Profile
            NavigationLink(destination: UserProfile(uid: userVM.id).navigationBarTitle("Profile", displayMode: .inline),
                           tag:1,
                           selection: self.$selection) {
                EmptyView()
            }
            
            // Create a new chatroom with user
            NavigationLink(destination: ChatRoomView().navigationBarTitle("Message \(userVM.user.name)", displayMode: .inline), tag: 2, selection: self.$selection) {
                    EmptyView()
            }

        }
    }
}
