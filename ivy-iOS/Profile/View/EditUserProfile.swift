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

struct EditUserProfile: View {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var userProfile = User()
    @State var loadingInProgress = false
    @State private var imgUrl = ""
    @State var nameInput = ""
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    

    
    func updatePosts(){
        db.collection("universities").document(userProfile.uni_domain).collection("posts").whereField("author_id", isEqualTo: userProfile.id ?? "").getDocuments { (querySnap, error) in
            if error != nil{
                print("We've got a problem hoss.")
                return
            }
            if let snap = querySnap {
                for doc in snap.documents{
                    doc.reference.updateData([
                        "author_name": self.nameInput
                    ])
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func saveChanges(){
        if(image != nil){ //image changed, gotta update that
            print(Utils.userProfileImagePath(userId: userProfile.id!))
            self.storageRef.child(Utils.userProfileImagePath(userId: userProfile.id!)).putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (metadata, error) in
                if(error != nil){
                    print("Error updating profile image.")
                    print(error?.localizedDescription ?? "")

                }
                self.storageRef.child(Utils.userPreviewImagePath(userId: self.userProfile.id!)).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (metadata1, error1) in
                    if(error1 != nil){
                        print("Error updating preview image.")
                        print(error1?.localizedDescription ?? "")
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        if(nameInput != userProfile.name){ //name changed, gotta update
            updatePosts() //also updat posts
            db.collection("users").document(userProfile.id!).updateData(["name" : nameInput]){error in
                if error != nil{
                    print("Error updating username.")
                }
                if(self.image == nil){ //only dismiss if we're also changing the image (that is guaranteed to take longer)
                    self.presentationMode.wrappedValue.dismiss()
                }
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
    
    
    
    
    
    // MARK: Body
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
                    
                    FirebaseImage(
                        path: self.userProfile.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 250,
                        height: 250,
                        shape: RoundedRectangle(cornerRadius: 125)
                    )
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
                    self.loadingInProgress = true
                    self.saveChanges()
                }){
                    Text("Save")
                }
                    .disabled(((!inputOk() || nameInput == userProfile.name) && image == nil) || loadingInProgress) //button blocked when either loading or when no changes at all
                .buttonStyle(StandardButtonStyle(disabled: ((!inputOk() || nameInput == userProfile.name) && image == nil) || loadingInProgress))
                
            }
        }
        .padding()
        .foregroundColor(Color.black)
        .keyboardAdaptive()
        .onTapGesture { //hide keyboard when background tapped
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
}

