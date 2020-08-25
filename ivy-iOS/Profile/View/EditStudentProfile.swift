//
//  EditStudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct EditStudentProfile: View {
    
    @ObservedObject var thisUserRepo: ThisUserRepo
    @ObservedObject var editStudentVM: EditStudentProfileViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showingImagePicker = false
    
    
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        self.editStudentVM = EditStudentProfileViewModel(thisUserRepo: thisUserRepo)
    }
    
    
    var body: some View {
        ScrollView {
            VStack() {
                
                // Profile Image
                if (editStudentVM.image != nil) {
                    editStudentVM.image!
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                } else {
                    FirebaseImage(
                        path: thisUserRepo.user.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 200,
                        height: 200,
                        shape: Circle()
                    )
                }
                
                // Change image
                Button(action: {
                    self.showingImagePicker = true
                }) {
                    Text("Change").foregroundColor(AssetManager.ivyGreen)
                        .sheet(isPresented: $showingImagePicker, onDismiss: editStudentVM.loadImage) {
                            ImagePicker(image: self.$editStudentVM.inputImage)
                    }
                }
                
                // Other Fields
                NameField(name: $editStudentVM.name)
                
                DropDownMenu(
                    selected: $editStudentVM.degree,
                    list: StaticDegreesList.degree_array,
                    hint: "Degree",
                    background: Color.white
                )
                
                Toggle(isOn: $editStudentVM.is_private) {
                    Text("Private Profile")
                }
                .padding(.bottom, 30.0)
                
                // Birthday
                HStack{
                    Text("Birthday")
                    Spacer()
                }
                DatePicker("", selection: $editStudentVM.selectedBD, in: ...Date(), displayedComponents: .date)
                

                // Display loading instead of button when waiting for results from Firebase
                HStack {
                    if (editStudentVM.waitingForResult) {
                        LoadingSpinner()
                    }
                    else {
                        Button(action: {
                            self.editStudentVM.updateInDB()
                        }){
                            Text("Save")
                        }
                            .disabled(!editStudentVM.inputOk() || editStudentVM.waitingForResult)
                            .buttonStyle(StandardButtonStyle(disabled: !editStudentVM.inputOk()))
                    }
                } // VM will send a signal whenever shouldDismiss changes value
                .onReceive(editStudentVM.viewDismissalModePublisher) { shouldDismiss in
                    if shouldDismiss {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                
                Spacer()
            }
            .padding()
            .keyboardAdaptive()
            .onTapGesture { //hide keyboard when background tapped
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
        }
    }
}
