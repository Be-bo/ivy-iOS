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
        ZStack(alignment: .bottomLeading) { // alignment is for banner
            // No visual?
            if (eventVM.event.visual.isEmpty || eventVM.event.visual == "nothing") {
                ProfileNoPicPostItemView(text: eventVM.event.name)
                .onTapGesture {
                    self.selection = self.eventVM.event.creation_millis
                    print("selected post: \(self.eventVM.event.text)")
                }
            } else {
                FirebaseImage(
                    path: Utils.postPreviewImagePath(postId: eventVM.id),
                    placeholder: AssetManager.logoGreen,
                    width: (UIScreen.screenWidth/3 - 20),
                    height: (UIScreen.screenWidth/3 - 20),
                    shape: RoundedRectangle(cornerRadius: 25)
                )
                .onTapGesture {
                    self.selection = self.eventVM.event.creation_millis
                    print("selected post: \(self.eventVM.event.text)")
                }
            }
            
            EventBanner()

            // TODO: quick and dirty
            NavigationLink(
                destination: EventScreenView(eventVM: eventVM)
                    .navigationBarTitle(eventVM.event.name),
                tag: eventVM.event.creation_millis, selection: self.$selection)
            { EmptyView() }
        }
    .padding(3)
    }
}

// POST ITEM
struct ProfilePostItemView: View {
    
    //var geo : GeometryProxy
    var postVM: HomePostViewModel
    @State private var selection: Int?
    
    var body: some View {
        ZStack {
                // No visual?
                if (postVM.post.visual.isEmpty || postVM.post.visual == "nothing") {
                    ProfileNoPicPostItemView(text: postVM.post.text)
                    .onTapGesture {
                        self.selection = self.postVM.post.creation_millis
                        print("selected post: \(self.postVM.post.text)")
                    }
                } else {
                    FirebaseImage(
                        path: Utils.postPreviewImagePath(postId: postVM.id),
                        placeholder: AssetManager.logoGreen,
                        width: (UIScreen.screenWidth/3 - 20),
                        height: (UIScreen.screenWidth/3 - 20),
                        shape: RoundedRectangle(cornerRadius: 25)
                    )
                    .onTapGesture {
                        self.selection = self.postVM.post.creation_millis
                        print("selected post: \(self.postVM.post.text)")
                    }
                }

            // TODO: quick and dirty
            NavigationLink(
                destination: PostScreen(postVM: postVM)
                    .navigationBarTitle(postVM.post.author_name+"'s Post"),
                tag: postVM.post.creation_millis ?? 1, selection: self.$selection)
            { EmptyView() }
        }
        .padding(3)
    }
}

// Post/Event item that doesn't have a pic
struct ProfileNoPicPostItemView: View {
    
    var text: String
    var width: CGFloat? = (UIScreen.screenWidth/3 - 20)
    var height: CGFloat? = (UIScreen.screenWidth/3 - 20)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(gradient: .init(colors: [AssetManager.ivyGreen, Color.white]), startPoint: .top, endPoint: .bottom))
            Text(text)
                .foregroundColor(.white)
                .padding(5)
        }
        .frame(width: width, height: height)
    }
}

// For events only
struct EventBanner: View {
    var body: some View {
        
        ZStack(alignment: .trailing) {
        
            Image(systemName: "bookmark.fill")
                .resizable()
                .frame(width: 20, height: 50)
                .foregroundColor(AssetManager.ivyAccent)
                .rotationEffect(.degrees(-90))

            
            Text("Event")
                .foregroundColor(.white)
                .font(.system(size:11.5))

        }
        
    }
}
