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
    @ObservedObject private var thisUserDataRepo: UserRepo
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @State private var selection = 2
    
    
    init(){
        if Auth.auth().currentUser != nil {
            thisUserDataRepo = UserRepo(userid: Auth.auth().currentUser!.uid)
        } else {
            thisUserDataRepo = UserRepo()
        }
        Utils.checkForUnverified()
    }
    
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView(selection: self.$selection) {
            
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                
                // MARK: CHAT
                ChatTabView(thisUserRepo: thisUserRepo)
                    .tabItem{
                        selection == 0 ? Image(systemName: "message.fill").font(.system(size: 25)) : Image(systemName: "message").font(.system(size: 25))
                        Text("Chat")
                }
                .tag(0)
            }


            // MARK: Events
            EventsTabView()
                .tabItem{
                    selection == 1 ? Image(systemName: "calendar").font(.system(size: 25)) : Image(systemName: "calendar").font(.system(size: 25))
                    Text("Events")
            }
            .tag(1)

            
            
            // MARK: Home
            HomeTabView(thisUserRepo: thisUserRepo)
                .tabItem {
                    selection == 2 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
                    Text("Home")
            }
            .tag(2)

            
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                
                // MARK: QUAD
                QuadTabView(thisUserRepo: thisUserRepo)
                    .tabItem{
                        selection == 3 ? Image(systemName: "person.2.square.stack.fill").font(.system(size: 25)) : Image(systemName: "person.2.square.stack").font(.system(size: 25))
                        Text("Quad")
                }
                .tag(3)
            

                // MARK: Profile
                ProfileTabView(uid: Auth.auth().currentUser!.uid)
                    .tabItem {
                        selection == 4 ? Image(systemName: "person.crop.circle.fill").font(.system(size: 25)) : Image(systemName: "person.crop.circle").font(.system(size: 25))
                        Text("Profile")
                }
                .tag(4)
            }

            
        }
        .accentColor(AssetManager.ivyGreen)
        .onDisappear {
            if(self.thisUserDataRepo.listenerRegistration != nil){
                self.thisUserDataRepo.removeListener()
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil{
                self.thisUserDataRepo.loadUserProfile()
            }
        }
    }
}



struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}



