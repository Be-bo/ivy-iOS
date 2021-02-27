//
//  CreatePostView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//
//  New Post
//  TODO: input check -> give feedback
//


import SwiftUI
import SDWebImageSwiftUI


struct CreatePostView: View {
    
    @ObservedObject private var createPostVM: CreatePostViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var visualPick = 0
    @State private var textInput = ""
    @State private var pinnedName: String?
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
        
    var editingMode = false
    var editModeType = 0
    
    
    // Check input before posting
    func inputOk() -> Bool{ //TODO: check date
        return !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    
    
    // MARK: INIT
    init(_ alreadyExistingPost: Post? = nil){
        self.createPostVM = CreatePostViewModel(post: alreadyExistingPost)
        self.editingMode = alreadyExistingPost != nil
    }
    
    
    
    // MARK: View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                if(self.editingMode){
                    Text("Edit Post").font(.largeTitle)
                        .foregroundColor(AssetManager.textColor)
                        .padding(.bottom, 10)

                    
                    Text("All values will be overwritten! (I.e. You'll have to fill out all the fields again, only comments & going users will be kept.)")
                        .foregroundColor(AssetManager.ivyNotificationRed)
                        .padding(.bottom, 10)
                }else{
                    Text("Create Post").font(.largeTitle)
                        .foregroundColor(AssetManager.textColor)
                        .padding(.bottom, 10)
                }
                
                // MARK: Type
//                if(!editingMode){
//                    HStack{
//                        Text("Type").font(.system(size: 25))
//                        Spacer()
//                    }
//                    Picker("Type", selection: typePick) {
//                        Text("Post").tag(0)
//                        Text("Event").tag(1)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding(.bottom, 10)
//                }
                
                // MARK: Visual
                HStack{
                    Text("Visual").font(.system(size: 25)).foregroundColor(AssetManager.textColor)
                    Spacer()
                }
                Picker("Visual", selection: $visualPick) {
                    Text("Nothing").tag(0)
                    Text("Image").tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)
                
                
                
                Group{ // background on click dismisses keyboard, couldn't apply to the entire layout because it bugs the segmented control
                    // MARK: Image Picker
                    if(visualPick == 1){
                        VStack {
                            Button(action: {
                                self.showingImagePicker = true
                            }) {
                                Text("Add Image").foregroundColor(AssetManager.ivyGreen)
                                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                                        ImagePicker(image: self.$inputImage)
                                }
                            }
                            if(image != nil){
                                image?.resizable().aspectRatio(1, contentMode: .fit)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // MARK: Text
                    TextField("Text", text: $textInput).foregroundColor(AssetManager.textColor)
                    Divider().padding(.bottom, 10)
                    
                    
                    // MARK: Pinned
                    if (self.createPostVM.pinnedNames.count > 0){
                        DropDownMenu(
                            selected: $pinnedName,
                            list: self.createPostVM.pinnedNames,
                            hint: "Pinned Event",
                            hintColor: AssetManager.ivyHintGreen,
                            expandedHeight: 200
                        )
                            .padding(.bottom, 10)
                    }
                    
                        
                    
                    
                    // MARK: Button
                    if(createPostVM.loadInProgress){
                        LoadingSpinner()
                    } else {
                        Button(action: {
                            if (self.editingMode) {
                                createPostVM.uploadEdittedPost(text: self.textInput, pin_name: self.pinnedName, image: self.inputImage)
                            } else {
                                createPostVM.uploadNewPost(text: self.textInput, pinnedName: self.pinnedName, image: self.inputImage)
                            }
                        }){
                            Text(editingMode ? "Edit" : "Post")
                        }
                        .disabled(!inputOk())
                        .buttonStyle(StandardButtonStyle(disabled: !inputOk()))
                    }
                }
                    .onTapGesture { //hide keyboard when background tapped
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                
            }
        }
        .foregroundColor(Color.black)
        .padding()
        .keyboardAdaptive()
        
        // Dismiss View when VM gives the signal
        .onReceive(self.createPostVM.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


