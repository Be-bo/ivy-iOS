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
        /*if #available(iOS 14.0, *) {
            WebImage(url: URL(string: imageURL))
                .placeholder(placeholder)
                .clipShape(shape)
                .onAppear(){
                    if (!self.path.isEmpty && self.path != "nothing") {
                        self.storage.child(self.path).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading image from storage: '\(path)'")
                                return
                            }
                            self.imageURL = "\(url!)"
                        }
                    }
            }
        } else {*/
            WebImage(url: URL(string: imageURL))
                .resizable()
                .placeholder(placeholder)
                .frame(width: width, height: height)
                .clipShape(shape)
                .onAppear(){
                    if (!self.path.isEmpty && self.path != "nothing") {
                        self.storage.child(self.path).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading image from storage: '\(path)'")
                                return
                            }
                            self.imageURL = "\(url!)"
                        }
                    }
            }
        //}
    }
}

// For posts/events only
struct FirebasePostImage: View{
    
    @State private var imageURL = ""
    let storage = Storage.storage().reference()

    var path: String
    var placeholder = AssetManager.logoGreen
    var width: CGFloat? = 105
    var height: CGFloat? = 105
    var shape = RoundedRectangle(cornerRadius: 25)
    
    
    var body: some View {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .placeholder(placeholder)
            .background(Color.white)
            .frame(width: width, height: height)
            .clipShape(shape)
            .onAppear(){
                if (!self.path.isEmpty && self.path != "nothing") {
                    self.storage.child(self.path).downloadURL { (url, err) in
                        if err != nil{
                            print("Error loading Post or Event image from storage: '\(path)'")
                            return
                        }
                        self.imageURL = "\(url!)"
                    }
                }
        }
    }
}

