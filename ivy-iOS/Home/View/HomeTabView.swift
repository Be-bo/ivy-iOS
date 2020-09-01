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
    var thisUserRepo: ThisUserRepo
    @State private var settingsPresented = false
    @State private var createPostPresented = false
    @State private var loginPresented = false
    @State private var notificationCenterPresented = false
    @State private var uniUrl = ""
    @ObservedObject var homeTabVM = HomeTabViewModel()
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                List(){
                    ForEach(homeTabVM.homePostsVMs){ postItemVM in
                        HomePostView(postItemVM: postItemVM)
                    }
                }
                
                if(homeTabVM.homePostsVMs.count < 1){
                    Text("No posts on this campus just yet!")
                        .font(.system(size: 25))
                        .foregroundColor(AssetManager.ivyLightGrey)
                        .multilineTextAlignment(.center)
                        .padding(30)
                }
            }
                
                
 
                //MARK: Nav Bar
            .navigationBarItems(leading:
                    HStack {
                        Button(action: {
                            self.settingsPresented.toggle()
                        }) {
                            Image(systemName: "gear").font(.system(size: 25))
                                .sheet(isPresented: $settingsPresented, onDismiss: {
                                    if(self.homeTabVM.currentUni != Utils.getCampusUni()){ //if uni changed, reload data, refresh uni logo
                                        self.homeTabVM.reloadData()
                                        self.homeTabVM.currentUni = Utils.getCampusUni()
                                        self.uniUrl = "test"
                                    }
                                }){
                                    SettingsView(thisUserRepo: self.thisUserRepo)
                            }
                        }
                        
                        WebImage(url: URL(string: self.uniUrl))
                            .resizable()
                            .placeholder(AssetManager.uniLogoPlaceholder)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(.leading, (UIScreen.screenWidth/2 - 75))
                            .onAppear(){
                                self.uniUrl = "test"
                                let storage = Storage.storage().reference()
                                storage.child(Utils.uniLogoPath()).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading uni logo image.")
                                        return
                                    }
                                    self.uniUrl = "\(url!)"
                                }
                        }
                        
                    }.padding(.leading, 0), trailing:
                    HStack {
                        if thisUserRepo.userLoggedIn {
                            Button(action: {
                                self.createPostPresented.toggle()
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 25))
                                    .sheet(isPresented: $createPostPresented, onDismiss: {
                                        self.homeTabVM.refresh()
                                    }) {
                                        CreatePostView(typePick: 0, alreadyExistingEvent: Event(), alreadyExistingPost: Post(), editingMode: false)
                                }
                            }
                        }
                        else {
                            Button(action: {
                                self.loginPresented.toggle()
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 25))
                                    .sheet(isPresented: $loginPresented) {
                                        LoginView(thisUserRepo: self.thisUserRepo)
                                }
                            }
                        }
                })
        }
        
    }
}
