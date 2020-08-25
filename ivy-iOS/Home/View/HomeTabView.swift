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
    @ObservedObject var homeTabVM = HomeTabViewModel()
    
    var body: some View {
        ZStack{
            Text(homeTabVM.homePostsVMs.count < 1 ? "No posts on this campus just yet!" : "").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(30)
            
            VStack{
                List(){
                    ForEach(homeTabVM.homePostsVMs){ postItemVM in
                        HomePostView(postItemVM: postItemVM)
                    }
                }
            }
        }
    }
}
