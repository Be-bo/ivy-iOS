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

    @Binding var path: String
    var placeholder: Image
    var width: CGFloat?
    var height: CGFloat?
    var shape: S
    
    
    // If you want to use a binding value
    init(path: Binding<String>, placeholder : Image, width: CGFloat? = 100, height: CGFloat? = 100, shape: S) {
        self._path = path
        self.placeholder = placeholder
        self.width = width
        self.height = height
        self.shape = shape
    }
    
    // Convenience
    init(path: String, placeholder : Image, width: CGFloat? = 100, height: CGFloat? = 100, shape: S) {
        self.init(path: Binding.constant(path), placeholder: placeholder, width: width, height: height, shape: shape)
    }
    
    
        
    var body: some View {
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


// For users in Quad only
struct FirebaseCardImage: View{
    
    @State private var imageURL = ""
    let storage = Storage.storage().reference()

    var path: String
    var placeholder = Image(systemName: "person.fill")
    var width: CGFloat? = UIScreen.screenWidth - (UIScreen.screenWidth * 0.1)
    var height: CGFloat? = UIScreen.screenHeight - (UIScreen.screenHeight * 0.29)
    let shape = RoundedRectangle(cornerRadius: 25)
    
    
    var body: some View {
        ZStack {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .placeholder(placeholder)
            .aspectRatio(contentMode: .fill)
            .onAppear(){
                if (!self.path.isEmpty && self.path != "nothing") {
                    self.storage.child(self.path).downloadURL { (url, err) in
                        if err != nil{
                            print("Error Card image from storage: '\(path)'")
                            return
                        }
                        self.imageURL = "\(url!)"
                    }
                }
            }
            
            LinearGradient(
                gradient: SwiftUI.Gradient(colors: [Color.white.opacity(0), .white]),
                startPoint: .center,
                endPoint: .bottom)
        }
        .frame(width: width, height: height)
        .clipShape(shape)
    }
}

