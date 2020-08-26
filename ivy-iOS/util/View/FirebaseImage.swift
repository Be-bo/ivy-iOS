//
//  FirebaseImage.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//
// References:
// https://benmcmahen.com/firebase-image-in-swiftui/
// https://firebase.google.com/docs/storage/ios/upload-files
//

import SwiftUI
import Combine
import FirebaseStorage
import SDWebImageSwiftUI


// Struct used for firebase images
struct FirebaseImage<S>: View where S:Shape{
    
    @State private var imageURL = ""
    let storage = Storage.storage().reference()

    var path: String
    var placeholder: Image
    var width: CGFloat? = 100
    var height: CGFloat? = 100
    var shape: S
    
        
    var body: some View {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .placeholder(placeholder)
            .frame(width: width, height: height)
            .clipShape(shape)
            .onAppear(){
                self.storage.child(self.path).downloadURL { (url, err) in
                    if err != nil{
                        print("Error loading image from storage.")
                        return
                    }
                    self.imageURL = "\(url!)"
                }
        }
    }
}

// For posts only
struct FirebasePostItem: View{
    
    @State private var imageURL = ""
    let storage = Storage.storage().reference()

    var path: String
    var placeholder = AssetManager.logoWhite
    var width: CGFloat? = 105
    var height: CGFloat? = 105
    var shape = RoundedRectangle(cornerRadius: 25)
    
    
    var body: some View {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .placeholder(placeholder)
            .background(AssetManager.ivyLightGrey)
            .frame(width: width, height: height)
            .clipShape(shape)
            .onAppear(){
                self.storage.child(self.path).downloadURL { (url, err) in
                    if err != nil{
                        print("Error loading image from storage.")
                        return
                    }
                    self.imageURL = "\(url!)"
                }
        }
    }
}

