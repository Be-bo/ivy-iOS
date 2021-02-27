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
    @ObservedObject var thisUserRepo : ThisUserRepo
    @State private var selection = 2
    
    
    init(){
        if Auth.auth().currentUser != nil {
            thisUserRepo = ThisUserRepo(userid: Auth.auth().currentUser!.uid)
        } else {
            thisUserRepo = ThisUserRepo()
        }
        Utils.checkForUnverified()
    }
    
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView(selection: self.$selection) {
            
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                
                // MARK: CHAT
                ChatTabView(thisUserRepo: thisUserRepo)
                    .onAppear(perform:{
                        print("CHAT TAB USER: \(thisUserRepo.user.name)")
                    })
                    .tabItem{
                        selection == 0 ? Image(systemName: "message.fill").font(.system(size: 25)) : Image(systemName: "message").font(.system(size: 25))
                        Text("Chat")
                }
                .tag(0)
            }


            // MARK: Events
            EventsTabView(thisUserRepo: thisUserRepo)
                .onAppear(perform:{
                    print("EVENT TAB USER: \(thisUserRepo.user.name)")
                })
                .tabItem{
                    selection == 1 ? Image(systemName: "calendar").font(.system(size: 25)) : Image(systemName: "calendar").font(.system(size: 25))
                    Text("Events")
            }
            .tag(1)

            
            
            // MARK: Home
            HomeTabView(thisUserRepo: thisUserRepo)
                .onAppear(perform:{
                    print("HOME TAB USER: \(thisUserRepo.user.name)")
                })
                .tabItem {
                    selection == 2 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
                    Text("Home")
            }
            .tag(2)

            
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                
                // MARK: QUAD
                QuadTabView(thisUserRepo: thisUserRepo)
                    .onAppear(perform:{
                        print("QUAD TAB USER: \(thisUserRepo.user.name)")
                    })
                    .tabItem{
                        selection == 3 ? Image(systemName: "person.2.square.stack.fill").font(.system(size: 25)) : Image(systemName: "person.2.square.stack").font(.system(size: 25))
                        Text("Quad")
                }
                .tag(3)
            

                // MARK: Profile
                ThisProfileTabView(thisUserRepo: thisUserRepo)
                    .onAppear(perform:{
                        print("PROFILE TAB USER: \(thisUserRepo.user.name)")
                    })
                    .tabItem {
                        selection == 4 ? Image(systemName: "person.crop.circle.fill").font(.system(size: 25)) : Image(systemName: "person.crop.circle").font(.system(size: 25))
                        Text("Profile")
                }
                .tag(4)
            }

            
        }
        .accentColor(AssetManager.ivyGreen)
        .onDisappear {
            if(self.thisUserRepo.listenerRegistration != nil){
                self.thisUserRepo.removeListener()
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil{
                self.thisUserRepo.loadUserProfile()
            }
        }
    }
}
