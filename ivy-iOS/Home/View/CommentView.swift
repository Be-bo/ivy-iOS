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
    
    
    
    
    var body: some View {
        HStack(alignment: .top){
            
            // MARK: Author
            FirebaseImage(
                path: Utils.userPreviewImagePath(userId: self.commentVM.comment.author_id),
                placeholder: Image(systemName: "person.crop.circle.fill"),
                width: 40,
                height: 40,
                shape: RoundedRectangle(cornerRadius: 20)
            )
            
            
            
            
            // MARK: Text/Image
            if(commentVM.comment.type == 1){ //type text
                Text(self.commentVM.comment.text).fixedSize(horizontal: false, vertical: true)
            }else if (commentVM.comment.type == 2){ //type image
                FirebaseImage(
                    path: self.commentVM.comment.text,
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: UIScreen.screenWidth - 150,
                    height: UIScreen.screenWidth - 150,
                    shape: RoundedRectangle(cornerRadius: 0)
                )
                
            }
            
            Spacer()
            
        }
        .padding(.horizontal)
//        .background(AssetManager.ivyLightGrey)
//        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
