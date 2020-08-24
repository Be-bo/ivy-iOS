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
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State var user = User()
    @State var selectedBD = Date()
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    var body: some View {
        ScrollView {
            VStack() {
                
                // Profile Image
                FirebaseImage(
                    path: thisUserRepo.thisUser.profileImagePath(),
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: 200,
                    height: 200,
                    shape: Circle()
                )
                
                // Change image
                Button(action: {
                    self.showingImagePicker = true
                }) {
                    Text("Change").foregroundColor(AssetManager.ivyGreen)
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }
                }
                if(image != nil){
                    image?.resizable().aspectRatio(contentMode: .fit)
                }
                
                // Other Fields
                NameField(name: $user.name)
                
                /*
                DropDownMenu(
                    selected: $user.degree,
                    list: StaticDegreesList.degree_array,
                    hint: "Degree",
                    background: Color.white
                )*/
 
                
                Toggle(isOn: $user.is_private) {
                    Text("Private Profile")
                }
                .padding(.bottom, 30.0)
                
                // Birthday
                DatePicker("Birthday", selection: $selectedBD, in: ...Date(), displayedComponents: .date)
                
                /* TODO
                
                // Display loading instead of button when waiting for results from Firebase
                HStack {
                    if (studentSignupVM.waitingForResult) {
                        LoadingSpinner()
                    }
                    else {
                        Button(action: {
                            self.studentSignupVM.attemptSignup()
                            self.errorText = nil
                        }){
                            Text("Sign Up")
                        }
                            .disabled(!studentSignupVM.nonEmpty() || studentSignupVM.waitingForResult)
                            .buttonStyle(StandardButtonStyle(disabled: !studentSignupVM.nonEmpty()))
                    }
                } // VM will send a signal whenever shouldDismiss changes value
                .onReceive(studentSignupVM.viewDismissalModePublisher) { shouldDismiss in
                    if shouldDismiss {
                        self.showAlert = true
                    } else { // There was an error -> identify and give feedback to user
                        if (!self.studentSignupVM.validDomain()) {
                            self.errorText = SignupError.invalidDomain
                        }
                        else if (!self.studentSignupVM.validEmail()) {
                            self.errorText = .invalidEmail
                        }
                        else if (self.studentSignupVM.degree == nil) {
                            self.errorText = .noDegreeSelected
                        }
                        else if (!self.studentSignupVM.validPassword()) {
                            self.errorText = .shortPassword
                        }
                        else if (!self.studentSignupVM.validConfirmPassword()) {
                            self.errorText = .invalidPasswordMatch
                        }
                        else {
                            self.errorText = .emailExists
                        }
                    }
                }
                
                Spacer()
 */
            }
        }
    }
}
