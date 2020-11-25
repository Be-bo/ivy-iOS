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
                
                // MARK: Chat Button
                ZStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                                self.selection = 1
                        }){
                            Image(systemName: "message.circle")
                                .font(.system(size: 35))
                                .foregroundColor(AssetManager.ivyGreen)
                        }
                    }
                
                    NavigationLink(destination: ChatRoomView().navigationBarTitle("Message \(userVM.user.name)", displayMode: .inline), tag: 1, selection: self.$selection) {
                            EmptyView()
                    }
                }
                
                Spacer()
                
                ZStack {
                    Button(action: {
                        self.selection = 2
                    }) {
                        Text(userVM.user.name).bold()
                    }
                    
                    // Go To User Profile
                    NavigationLink(destination: UserProfile(uid: userVM.id).navigationBarTitle("Profile", displayMode: .inline),
                                   tag:2,
                                   selection: self.$selection) {
                        EmptyView()
                    }
                }
                
                Text(userVM.user.degree ?? "")
            }
            .padding()
            .padding(.bottom, 40)
            .background(LinearGradient(
                            gradient: SwiftUI.Gradient(colors: [Color.white.opacity(0), .white]),
                            startPoint: .center,
                            endPoint: .bottom))

        }
    }
}
