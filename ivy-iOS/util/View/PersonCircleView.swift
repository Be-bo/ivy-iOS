//
//  PersonCircleView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PersonCircleView: View {
    var personId: String = ""
    @State var url = ""
    
    var body: some View {
        WebImage(url: URL(string: self.url))
            .resizable()
            .placeholder(Image(systemName: "person.crop.circle.fill"))
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .padding(.leading)
            .onAppear(){
                let storage = Storage.storage().reference()
                storage.child(Utils.userPreviewImagePath(userId: self.personId)).downloadURL { (url, err) in
                    if err != nil{
                        print("Error loading person circle image.")
                        return
                    }
                    self.url = "\(url!)"
                }
        }
    }
}
