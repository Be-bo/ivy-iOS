//
//  Main.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-07-09.
//  Copyright © 2020 ivy. All rights reserved.
//

//sceneDelegate calls this view as the first view when the app is launched.
//Since you can login without an account it will always open up to Main



import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct Main: View {
    
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @State private var settingsPresented = false
    @State private var createPostOrLoginPresented = false
    @State private var notificationCenterPresented = false
    @State private var selection = 0
    @State private var showingSignOutAlert = false
    @ObservedObject var uniInfo = UniInfo()
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView() {
            
            
            // MARK: Events
            NavigationView{
                EventsTabView(screenWidth: UIScreen.screenWidth)
                    .navigationBarItems(leading:
                        HStack {
                            Button(action: {
                                self.settingsPresented.toggle()
                            }) {
                                Image(systemName: "gear").font(.system(size: 25))
                                    .sheet(isPresented: $settingsPresented){
                                        SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                                }
                            }
                            
                            WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                                .resizable()
                                .placeholder(AssetManager.uniLogoPlaceholder)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .padding(.leading, (UIScreen.screenWidth/2 - 80))
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
                        HStack {
                            Button(action: {
                                self.createPostOrLoginPresented.toggle()
                            }) {
                                Image(systemName: thisUserRepo.userLoggedIn ? "square.and.pencil" : "arrow.right.circle").font(.system(size: 25))
                                    .sheet(isPresented: $createPostOrLoginPresented){
                                        if(self.thisUserRepo.userLoggedIn){
                                            CreatePostView(thisUser: self.thisUserRepo.user)
                                        }else{
                                            LoginView()
                                        }
                                }
                            }
                    })
            }
            .tabItem{
                selection == 0 ? Image(systemName: "calendar").font(.system(size: 25)) : Image(systemName: "calendar").font(.system(size: 25))
            }
            .tag(0)
            
            
            
            
            
            
            // MARK: Home
            VStack{
                NavigationView{
                    HomeTabView()
                        .navigationBarItems(leading:
                            HStack {
                                Button(action: {
                                    self.settingsPresented.toggle()
                                }) {
                                    Image(systemName: "gear").font(.system(size: 25))
                                        .sheet(isPresented: $settingsPresented){
                                            SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                                    }
                                }
                                
                                WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                                    .resizable()
                                    .placeholder(AssetManager.uniLogoPlaceholder)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .padding(.leading, (UIScreen.screenWidth/2 - 80))
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
                            HStack {
                                Button(action: {
                                    self.createPostOrLoginPresented.toggle()
                                }) {
                                    Image(systemName: thisUserRepo.userLoggedIn ? "square.and.pencil" : "arrow.right.circle").font(.system(size: 25))
                                        .sheet(isPresented: $createPostOrLoginPresented){
                                            if(self.thisUserRepo.userLoggedIn){
                                                CreatePostView(thisUser: self.thisUserRepo.user)
                                            }else{
                                                LoginView()
                                            }
                                    }
                                }
                        }
                    )
                }
            .navigationBarHidden(false)
            }
            .tabItem {
                selection == 1 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
            }
            .tag(1)
            
            
            
            
            
            
            // MARK: Profile
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                VStack{
                    NavigationView {
                        
                        //TODO: quick and dirty
                        if thisUserRepo.user.is_organization {
                            OrganizationProfile(
                                userRepo: self.thisUserRepo,
                                postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_ORG, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))
                                .navigationBarItems(leading:
                                    HStack {
                                            Button(action: {
                                                self.settingsPresented.toggle()
                                            }) {
                                                Image(systemName: "gear").font(.system(size: 25))
                                                    .sheet(isPresented: $settingsPresented){
                                                        SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                                                }
                                            }
                                            
                                            WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                                                .resizable()
                                                .placeholder(AssetManager.uniLogoPlaceholder)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .padding(.leading, (UIScreen.screenWidth/2 - 80))
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
                                        HStack {
                                            Button(action: {
                                                self.notificationCenterPresented.toggle()
                                            }) {
                                                Image(systemName: "bell").font(.system(size: 25))
                                                    .sheet(isPresented: $notificationCenterPresented){
                                                        NotificationCenterView()
                                                }
                                            }
                                    }
                            )
                        } else {
                            StudentProfile(
                                userRepo: self.thisUserRepo,
                                postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_STUDENT, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))
                                .navigationBarItems(leading:
                                    HStack {
                                            Button(action: {
                                                self.settingsPresented.toggle()
                                            }) {
                                                Image(systemName: "gear").font(.system(size: 25))
                                                    .sheet(isPresented: $settingsPresented){
                                                        SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                                                }
                                            }
                                            
                                            WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                                                .resizable()
                                                .placeholder(AssetManager.uniLogoPlaceholder)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .padding(.leading, (UIScreen.screenWidth/2 - 80))
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
                                        HStack {
                                            Button(action: {
                                                self.notificationCenterPresented.toggle()
                                            }) {
                                                Image(systemName: "bell").font(.system(size: 25))
                                                    .sheet(isPresented: $notificationCenterPresented){
                                                        NotificationCenterView()
                                                }
                                            }
                                    }
                            )
                        }
                    }
                }
                .tabItem {
                    selection == 2 ? Image(systemName: "person.crop.circle.fill").font(.system(size: 25)) : Image(systemName: "person.crop.circle").font(.system(size: 25))
                }
                .tag(2)
            }
            
        }
        .accentColor(AssetManager.ivyGreen)
    }
}



struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

