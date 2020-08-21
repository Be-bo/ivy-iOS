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


// Struct similar to Image used for firebase images
struct FirebaseImage: View {
    
    @ObservedObject private var imageLoader: Loader
    var placeholder: UIImage
    
    init(id: String, _ placeholderName: String = "placeholder.jpg") {
        self.imageLoader = Loader(id)
        self.placeholder = UIImage(named: placeholderName)!
    }
    
    var image: UIImage? {
        imageLoader.data.flatMap(UIImage.init)
    }
    
    var body: some View {
        Image(uiImage: image ?? placeholder)
    }
}

// Loader to load images from firebase storage
final class Loader : ObservableObject {
    
    let didChange = PassthroughSubject<Data?, Never>()
    var data: Data? = nil {
        didSet {
            didChange.send(data)
        }
    }
    
    init(_ imgPath: String) {
        let storage = Storage.storage()
        
        storage.reference().child(imgPath)
            .getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("\(error)")
                }
                
                DispatchQueue.main.async {
                    self.data = data
                }
        }
        
    }
}
