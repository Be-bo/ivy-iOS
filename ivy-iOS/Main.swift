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

struct Main: View {
    @State var loginPresented = false
    @State private var selection = 0
    @State private var loggedIn = false
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView(selection: $selection) {
            
            // MARK: Events
            NavigationView{
                EventsTabView()
                    .navigationBarItems(leading:
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "gear").font(.system(size: 25))
                            }
                            AssetManager.ucInterlock.padding(.leading, UIScreen.screenWidth/2 - 82)
                        }.padding(.leading, 0), trailing:
                        HStack {
                            Button(action: {}) {
                                loggedIn == true ? Image(systemName: "square.and.pencil").font(.system(size: 25)) : Image(systemName: "arrow.right.circle").font(.system(size: 25))
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
                    Text("Home")
                    .navigationBarItems(leading:
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "gear").font(.system(size: 25))
                            }
                            AssetManager.ucInterlock.padding(.leading, UIScreen.screenWidth/2 - 82)
                        }.padding(.leading, 0), trailing:
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "square.and.pencil").font(.system(size: 25))
                            }
                    })
                }
            }
            .tabItem {
                selection == 1 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
            }
            .tag(1)
            
            
            
            // MARK: Profile
            VStack{
                NavigationView {
                    
                    StudentProfile(student: Student(id: "HaJEXFHBNhgLrHm0EhSjgR0KXhF2", email: "test4@asd.ca", degree: "Computer Science"))
                        
                        .navigationBarItems(leading:
                            HStack {
                                    Button(action: {}) {
                                        Image(systemName: "gear").font(.system(size: 25))
                                    }
                                    AssetManager.ucInterlock.padding(.leading, UIScreen.screenWidth/2 - 82)
                                }.padding(.leading, 0), trailing:
                                HStack {
                                    Button(action: {
                                        self.loginPresented.toggle()
                                    }) {
                                        Image(systemName: "person.crop.circle").font(.system(size: 25))
                                    }.sheet(isPresented: $loginPresented){
                                        LoginView()
                                    }
                            }
                    )
                }
            }
            .tabItem {
                selection == 2 ? Image(systemName: "person.fill").font(.system(size: 25)) : Image(systemName: "person").font(.system(size: 25))
            }
            .tag(2)
            
            
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
