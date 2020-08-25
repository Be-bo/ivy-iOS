//
//  UserProfileSupport.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-25.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// EVENT ITEM
struct ProfileEventItemView: View {
    
    //var geo : GeometryProxy
    var eventVM: EventItemViewModel
    @State private var selection: Int?
    
    var body: some View {
        ZStack {
                FirebaseImage(
                    path: Utils.postPreviewImagePath(postId: eventVM.id),
                    placeholder: AssetManager.logoGreen,
                    width: 105,
                    height: 105,
                    shape: RoundedRectangle(cornerRadius: 25)
                )
                    .onTapGesture {
                        self.selection = self.eventVM.event.creation_millis
                        print("selected post: \(self.eventVM.event.text)")
                }

            // TODO: quick and dirty
            NavigationLink(
                destination: EventScreenView(eventVM: eventVM)
                    .navigationBarTitle(eventVM.event.author_name+"'s Post"),
                tag: eventVM.event.creation_millis, selection: self.$selection)
            { EmptyView() }
        }
    }
}

// POST ITEM
struct ProfilePostItemView: View {
    
    //var geo : GeometryProxy
    var postVM: HomePostViewModel
    @State private var selection: Int?
    
    var body: some View {
        ZStack {
                FirebaseImage(
                    path: Utils.postPreviewImagePath(postId: postVM.id),
                    placeholder: AssetManager.logoGreen,
                    width: 105,
                    height: 105,
                    shape: RoundedRectangle(cornerRadius: 25)
                )
                    .onTapGesture {
                        self.selection = self.postVM.post.creation_millis ?? 1
                        print("selected post: \(self.postVM.post.text)")
                }

            // TODO: quick and dirty
            NavigationLink(
                destination: PostScreen(postVM: postVM)
                    .navigationBarTitle(postVM.post.author_name+"'s Post"),
                tag: postVM.post.creation_millis ?? 1, selection: self.$selection)
            { EmptyView() }
        }
    }
}
