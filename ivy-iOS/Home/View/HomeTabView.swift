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
    @State private var loadingWheelAnimating = true
    @ObservedObject var homeTabVM = HomeTabViewModel()
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                List(){
                    ForEach(homeTabVM.homePostsVMs){ postItemVM in
                        HomePostView(postItemVM: postItemVM)
                    }
                    
                    if homeTabVM.homeRepo.postsLoaded == false {
                        HStack{
                            Spacer()
                            ActivityIndicator($loadingWheelAnimating)
                                .onAppear {
                                    self.homeTabVM.homeRepo.fetchBatch()
                                }
                            Spacer()
                        }
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
                                    if(self.homeTabVM.currentUni != Utils.getCampusUni()){ // if uni changed, reload data, refresh uni logo
                                        self.homeTabVM.reloadData()
                                        self.homeTabVM.currentUni = Utils.getCampusUni()
                                        self.uniUrl = "test"
                                    }
                                }){
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
                                        CreatePostView()
                                }
                            }
                        }
                        else {
                            Button(action: {
                                self.loginPresented.toggle()
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 25))
                                    .sheet(isPresented: $loginPresented, onDismiss: {
                                        Utils.checkForUnverified()
                                    }) {
                                        LoginView(thisUserRepo: self.thisUserRepo)
                                }
                            }
                        }
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}
