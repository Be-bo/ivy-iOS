//
//  ProfileTabView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//
//  TODO: profile image doesn't update automatically after edit
//

import SwiftUI
import FirebaseAuth

struct ProfileTabView: View {
    
    var uid = ""
    @ObservedObject var profileVM : ProfileViewModel
    @ObservedObject var thisUserRepo = ThisUserRepo()


    @State var userPicUrl = ""
    @State var editProfilePresented = false
    @State var settingsPresented = false

    
    init(uid: String) {
        self.profileVM = ProfileViewModel(uid: uid)
        self.userPicUrl = Utils.userProfileImagePath(userId: uid)
        self.uid = uid
    }
    
    
    var body: some View {
        
        NavigationView{
            
            UserProfile(thisUserRepo: self.thisUserRepo, profileVM: self.profileVM, picUrl: $userPicUrl, uid: uid)
                .onAppear(){
                    self.userPicUrl = Utils.userProfileImagePath(userId: uid)
                }

            //MARK: Nav Bar
            .navigationBarItems(
                leading:
                    HStack {
                        
                        // MARK: Settings
                        Button(action: {
                            self.settingsPresented.toggle()
                        }) {
                            Image(systemName: "gear").font(.system(size: 25))
                                .sheet(isPresented: $settingsPresented){
                                    SettingsView(thisUserRepo: self.thisUserRepo)
                            }
                        }
                        
                        // MARK: Uni Logo
                        FirebaseImage(
                            path: Utils.uniLogoPath(),
                            placeholder: AssetManager.uniLogoPlaceholder,
                            width: 40,
                            height: 40,
                            shape: RoundedRectangle(cornerRadius: 0)
                        )
                        .padding(.leading, (UIScreen.screenWidth/2 - 75))
                        
                    }.padding(.leading, 0),
                
                trailing:
                    
                    // MARK: Edit Profile
                    Button(action: {
                        self.editProfilePresented.toggle()
                    }){
                        Image(systemName: "pencil").font(.system(size: 25))
                            .sheet(isPresented: $editProfilePresented, onDismiss: {
                            self.userPicUrl = "NEW PATH"
                        }){
                            EditUserProfile(
                                userProfile: self.profileVM.profileRepo.userProfile,
                                nameInput: self.profileVM.profileRepo.userProfile.name
                            )
                        }
                    }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
