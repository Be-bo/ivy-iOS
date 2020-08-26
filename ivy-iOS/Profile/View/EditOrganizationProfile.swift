//
//  EditOrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct EditOrganizationProfile: View {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var userProfile = User()
    @State private var imgUrl = ""
    @State var nameInput = ""
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func saveChanges(){
        if(image != nil){ //image changed, gotta update that
            self.storageRef.child(Utils.userProfileImagePath(userId: userProfile.id!)).putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                if(error != nil){
                    print(error)
                }
                self.storageRef.child(Utils.userPreviewImagePath(userId: self.userProfile.id!)).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                    if(error1 != nil){
                        print(error1)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        if(nameInput != userProfile.name){ //name changed, gotta update
            db.collection("users").document(userProfile.id!).updateData(["name" : nameInput]){error in
                if error != nil{
                    print("Error updating username.")
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func inputOk() -> Bool{
        if(!nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            return true
        }else{
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack() {
                
                // MARK: Image
                if(image != nil){
                    image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                }else{
                    WebImage(url: URL(string: imgUrl))
                        .resizable()
                        .placeholder(Image(systemName: "person.crop.circle.fill"))
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(Utils.userProfileImagePath(userId: self.userProfile.id ?? "")).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading event image.")
                                    return
                                }
                                self.imgUrl = "\(url!)"
                            }
                    }
                }
                
                
                
                
                // MARK: Change Image
                Button(action: {
                    self.showingImagePicker = true
                }) {
                    Text("Change").foregroundColor(AssetManager.ivyGreen)
                        .padding(.bottom, 10)
                        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: self.$inputImage)
                    }
                }
                
                
                
                // MARK: Name
                TextField("Username", text: $nameInput)
                Divider().padding(.bottom, 20)
                
                
                // MARK: Save Button
                Button(action: {
                    self.saveChanges()
                }){
                    Text("Save")
                }
                .disabled(!inputOk())
                .buttonStyle(StandardButtonStyle(disabled: !inputOk()))
                
            }
        }
        .padding()
        .keyboardAdaptive()
        .onTapGesture { //hide keyboard when background tapped
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
}

