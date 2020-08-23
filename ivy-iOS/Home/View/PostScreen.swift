//
//  PostScreen.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PostScreen: View {
    @ObservedObject var postVM: HomePostViewModel
    @State var imageUrl = ""
    @State var authorUrl = ""
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                //MARK: Image
                WebImage(url: URL(string: self.imageUrl))
                    .resizable()
                    .placeholder(AssetManager.logoWhite)
                    .background(AssetManager.ivyLightGrey)
                    .aspectRatio(contentMode: .fit)
                    .onAppear(){
                        let storage = Storage.storage().reference()
                        storage.child(self.postVM.post.visual).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading post screen image.")
                                return
                            }
                            self.imageUrl = "\(url!)"
                        }
                }
                
                
                Group{
                    //MARK: Author Row
                    HStack(){
                        WebImage(url: URL(string: authorUrl))
                            .resizable()
                            .placeholder(Image(systemName: "person.crop.circle.fill"))
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                storage.child(Utils.userPreviewImagePath(userId: self.postVM.post.author_id)).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading post screen author image.")
                                        return
                                    }
                                    self.authorUrl = "\(url!)"
                                }
                        }
                        Text(self.postVM.post.author_name)
                        Spacer()
                    }
                    
                    // MARK: Pinned Layout
                    if(self.postVM.post.pinned_id != "" && self.postVM.post.pinned_id != "nothing"){
                        HStack{
                            Image(systemName: "pin.fill").rotationEffect(Angle(degrees: -45)).padding(.leading, 5)
                            Text(self.postVM.post.pinned_name)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // MARK: Text
                    Text(postVM.post.text).multilineTextAlignment(.leading)
                }
                .padding(.leading)
                .padding(.trailing)
                
                
                
                Divider().padding(.top, 20).padding(.bottom, 20)
                // TODO: Comments
            }
        }
    }
}

