//
//  UserProfileNavView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2021-01-03.
//  Copyright © 2021 ivy. All rights reserved.
//
//  ThirdView User Profile
//

import SwiftUI

struct UserProfileNavView: View {
    
    var uid : String
    @ObservedObject var thisUserRepo: ThisUserRepo
    @State var showingAlert = false

    
    // Use this one if possible
    init(uid: String, thisUserRepo: ThisUserRepo) {
        self.uid = uid
        self.thisUserRepo = thisUserRepo
    }
    
    // For convenience
    init(uid: String) {
        self.init(uid: uid, thisUserRepo: ThisUserRepo())
    }
    
    
    
    var body: some View {
        
        UserProfile(uid: uid)

            // Title
            .navigationBarTitle("Profile", displayMode: .inline)
            
            // Block
            .navigationBarItems(trailing:
                Button(action: {
                    if (thisUserRepo.user.blocked_users?.contains(uid) ?? false) {
                        thisUserRepo.unblockUser(userID: uid)
                    } else {
                        showingAlert = true
                    }
                }) {
                    Text((thisUserRepo.user.blocked_users?.contains(uid) ?? false) ? "Unblock" : "Block")
                        .fontWeight(.regular)
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Block User?"), message: Text("You will not be able to message this user until you unblock them."), primaryButton: .destructive(Text("Block User")) {
                        thisUserRepo.blockUser(userID: uid)
                    }, secondaryButton: .cancel())
                }
            )
            .navigationViewStyle(StackNavigationViewStyle())
    }
}
