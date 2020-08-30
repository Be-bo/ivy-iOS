//
//  CommentView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct CommentView: View {
    @ObservedObject var commentVM: CommentViewModel
    @State var url = "" //comment image
    @State var authorUrl = "" //author image
    @State var selection: Int? = nil
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    
    
    var body: some View {
        HStack(alignment: .top){
            
            // MARK: Author
            WebImage(url: URL(string: authorUrl))
            .resizable()
            .placeholder(Image(systemName: "person.crop.circle.fill"))
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .onAppear(){
                let storage = Storage.storage().reference()
                storage.child(Utils.userPreviewImagePath(userId: self.commentVM.comment.author_id)).downloadURL { (url, err) in
                    if err != nil{
                        print("Error loading comment author image.")
                        return
                    }
                    self.authorUrl = "\(url!)"
                }
            }
            
            
            
            
            // MARK: Text/Image
            if(commentVM.comment.type == 1){ //type text
                Text(self.commentVM.comment.text)
            }else if (commentVM.comment.type == 2){ //type image
                WebImage(url: URL(string: url))
                .resizable()
                .placeholder(Image(systemName: "photo"))
                .aspectRatio(contentMode: .fit)
                .onAppear(){
                    let storage = Storage.storage().reference()
                    storage.child(self.commentVM.comment.text).downloadURL { (url, err) in
                        if err != nil{
                            print("Error loading comment image.")
                            print(err?.localizedDescription)
                            return
                        }
                        self.url = "\(url!)"
                    }
                }
            }
            
            Spacer()
            
        }
        .padding(.horizontal)
//        .background(AssetManager.ivyLightGrey)
//        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
