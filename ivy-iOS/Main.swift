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

struct Main: View {
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @State var sheetPresented = false
    @State private var selection = 0
    @State private var showingSignOutAlert = false
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView() {
            
            // MARK: Events
            NavigationView{
                EventsTabView(screenWidth: UIScreen.screenWidth)
                    .navigationBarItems(leading:
                        HStack {
                            Button(action: {
                                try? Auth.auth().signOut()
                            }) {
                                Image(systemName: thisUserRepo.userLoggedIn ? "arrow.left.circle" : "").font(.system(size: 25))
                                .alert(isPresented: $showingSignOutAlert){
                                    Alert(title: Text("Signed Out"), message: Text("You've been signed out."), dismissButton: .default(Text("OK")))
                                }
                            }
                            AssetManager.ucInterlock.padding(.leading, self.thisUserRepo.userLoggedIn ? UIScreen.screenWidth/2 - 82 : UIScreen.screenWidth/2 - 57)
                        }.padding(.leading, 0), trailing:
                        HStack {
                            Button(action: {
                                self.sheetPresented.toggle()
                            }) {
                                Image(systemName: thisUserRepo.userLoggedIn ? "square.and.pencil" : "arrow.right.circle").font(.system(size: 25))
                                    .sheet(isPresented: $sheetPresented){
                                        if(self.thisUserRepo.userLoggedIn){
                                            CreatePostView(thisUser: self.thisUserRepo.thisUser)
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
                                Button(action: {}) {
                                    Image(systemName: thisUserRepo.userLoggedIn ? "arrow.left.circle" : "").font(.system(size: 25))
                                    .alert(isPresented: $showingSignOutAlert){
                                        Alert(title: Text("Signed Out"), message: Text("You've been signed out."), dismissButton: .default(Text("OK")))
                                    }
                                }
                                AssetManager.ucInterlock.padding(.leading, self.thisUserRepo.userLoggedIn ? UIScreen.screenWidth/2 - 82 : UIScreen.screenWidth/2 - 57)
                            }.padding(.leading, 0), trailing:
                            HStack {
                                Button(action: {
                                    self.sheetPresented.toggle()
                                }) {
                                    Image(systemName: thisUserRepo.userLoggedIn ? "square.and.pencil" : "arrow.right.circle").font(.system(size: 25))
                                        .sheet(isPresented: $sheetPresented){
                                            if(self.thisUserRepo.userLoggedIn){
                                                CreatePostView(thisUser: self.thisUserRepo.thisUser)
                                            }else{
                                                LoginView()
                                            }
                                    }
                                }
                        })
                }
            }
            .tabItem {
                selection == 1 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
            }
            .tag(1)
            
            
            
            
            
            
            // MARK: Profile
            if(thisUserRepo.userLoggedIn){
                VStack{
                    Text("Profile").padding()
                }
                .tabItem {
                    selection == 2 ? Image(systemName: "person.fill").font(.system(size: 25)) : Image(systemName: "person").font(.system(size: 25))
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

