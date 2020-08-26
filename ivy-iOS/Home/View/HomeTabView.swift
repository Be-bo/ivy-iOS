//
//  HomeTabView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct HomeTabView: View {
    @ObservedObject var uniInfo = UniInfo()
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @State private var settingsPresented = false
    @State private var createPostOrLoginPresented = false
    @State private var notificationCenterPresented = false
    @ObservedObject var homeTabVM = HomeTabViewModel()
    
    var body: some View {
        
        NavigationView{
            ZStack{
                if !homeTabVM.homeRepo.postsLoaded {
                    LoadingSpinner().frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .center)
                }
                else {
                    Text(homeTabVM.homePostsVMs.count < 1 ? "No posts on this campus just yet!" : "")
                        .font(.system(size: 25))
                        .foregroundColor(AssetManager.ivyLightGrey)
                        .multilineTextAlignment(.center)
                        .padding(30)
                    
                    VStack{
                        List(){
                            ForEach(homeTabVM.homePostsVMs){ postItemVM in
                                HomePostView(postItemVM: postItemVM)
                            }
                        }
                    }
                }
            }
            
                //MARK: Nav Bar
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
        
    }
}