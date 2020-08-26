//
//  UserProfileTabView.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-26.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct UserProfileTabView: View {
    
    @ObservedObject var uniInfo = UniInfo()
    @ObservedObject var thisUserRepo : ThisUserRepo
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                if thisUserRepo.user.is_organization {
                    OrganizationProfile(
                        userRepo: self.thisUserRepo,
                        postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_ORG, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))


                } else {
                    StudentProfile(
                    userRepo: self.thisUserRepo,
                    postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_STUDENT, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))
                }
            }
            // MARK: Nav Bar
            .navigationBarItems(leading:
                HStack {
                    
                    // Settings
                    Button(action: {
                        self.settingsPresented.toggle()
                    }) {
                        Image(systemName: "gear").font(.system(size: 25))
                            .sheet(isPresented: $settingsPresented){
                                SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                        }
                    }
                    
                    // Uni Logo
                    WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                        .resizable()
                        .placeholder(AssetManager.uniLogoPlaceholder)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(.leading, (UIScreen.screenWidth/2 - 75))
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(Utils.uniLogoPath()).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading uni logo image.")
                                    return
                                }
                                self.uniInfo.uniLogoUrl = "\(url!)"
                            }
                    }
                    
                }.padding(.leading, 0), trailing:
                
                // Notifications
                HStack {
                    Button(action: {
                        self.notificationCenterPresented.toggle()
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 25))
                            .sheet(isPresented: $notificationCenterPresented){
                                NotificationCenterView()
                        }
                    }
                })
        }
    }
}
