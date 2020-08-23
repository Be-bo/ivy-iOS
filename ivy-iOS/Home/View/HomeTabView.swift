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
        VStack{
            List(){
                ForEach(homeTabVM.homePostsVMs){ postItemVM in
                    HomePostView(postItemVM: postItemVM)
                }
            }
        }
    }
}
