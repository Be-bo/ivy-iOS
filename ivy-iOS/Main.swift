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
    @State private var selection = 1
    
    
    var body: some View {
        
        
        // MARK: Tab Bar
        TabView(selection: self.$selection) {
            
            
            // MARK: Events
            EventsTabView(screenWidth: UIScreen.screenWidth)
                .tabItem{
                    selection == 0 ? Image(systemName: "calendar").font(.system(size: 25)) : Image(systemName: "calendar").font(.system(size: 25))
            }
            .tag(0)
            
            
            // MARK: Home
            HomeTabView()
                .tabItem {
                    selection == 1 ? Image(systemName: "house.fill").font(.system(size: 25)) : Image(systemName: "house").font(.system(size: 25))
            }
            .tag(1)
            
            
            
            // MARK: Profile
            if (thisUserRepo.userLoggedIn && thisUserRepo.userDocLoaded) {
                if thisUserRepo.user.is_organization {
                    OrganizationProfile(
                        userRepo: self.thisUserRepo,
                        postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_ORG, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))
                    .tabItem {
                        selection == 2 ? Image(systemName: "person.crop.circle.fill").font(.system(size: 25)) : Image(systemName: "person.crop.circle").font(.system(size: 25))
                        }
                    .tag(3)

                } else {
                    StudentProfile(
                    userRepo: self.thisUserRepo,
                    postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_STUDENT, uni_domain: thisUserRepo.user.uni_domain, user_id: thisUserRepo.user.id ?? ""))
                    .tabItem {
                        selection == 2 ? Image(systemName: "person.crop.circle.fill").font(.system(size: 25)) : Image(systemName: "person.crop.circle").font(.system(size: 25))
                        }
                    .tag(2)
                }
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



