//
//  CreateEventView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-05.
//  Copyright © 2020 ivy. All rights reserved.
//
//  New Event
//

import SwiftUI
import SDWebImageSwiftUI


struct CreateEventView: View {
    
    @ObservedObject private var createEventRepo = CreateEventRepo()
    @State private var loadInProgress = false
    var typePick = 0
    @State private var visualPick = 0
    @State private var textInput = ""
    @State private var eventName = ""
    @State private var location = ""
    @State private var link = ""
    @State private var pinnedName: String?
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    var alreadyExistingEvent = Event()
    var alreadyExistingPost = Post()
    var editingMode = false
    var editModeType = 0
    private var notificationSender = NotificationSender()
    
    
    
    // MARK: Functions
    
    
    func inputOk() -> Bool{ //TODO: check date
        return ((typePick == 0 && !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || //post
            
            (typePick == 1 && !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && //event
                !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    
    
    init(alreadyExistingPost: Post, editingMode: Bool){
        self.typePick = typePick
        self.alreadyExistingPost = alreadyExistingPost
        self.editingMode = editingMode
    }
    
    
    

    // MARK: View
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                if(self.editingMode){
                    if(typePick == 0){
                        Text("Edit Post").font(.largeTitle).padding(.bottom, 10)
                            .foregroundColor(AssetManager.textColor)
                    }else{
                        Text("Edit Event").font(.largeTitle).padding(.bottom, 10)
                            .foregroundColor(AssetManager.textColor)
                    }
                    Text("All values will be overwritten! (I.e. You'll have to fill out all the fields again, only comments & going users will be kept.)").foregroundColor(AssetManager.ivyNotificationRed).padding(.bottom, 10)
                }else{
                    if(typePick == 0){
                        Text("Create Post").font(.largeTitle).padding(.bottom, 10)
                            .foregroundColor(AssetManager.textColor)
                    }else{
                        Text("Create Event").font(.largeTitle).padding(.bottom, 10)
                            .foregroundColor(AssetManager.textColor)
                    }
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
                    if(typePick == 0){
                        TextField("Text", text: $textInput).foregroundColor(AssetManager.textColor)
                    }else{
                        TextField("Description", text: $textInput).foregroundColor(AssetManager.textColor)
                    }
                    Divider().padding(.bottom, 10)
                    
                    
                    // MARK: Pinned
                    if(typePick == 0){
                        DropDownMenu(
                            selected: $pinnedName,
                            list: self.createPostRepo.pinnedNames,
                            hint: "Pinned Event",
                            hintColor: AssetManager.ivyHintGreen,
                            expandedHeight: 200
                        )
                            .padding(.bottom, 10)
                        
                        
                        // MARK: Event Fields
                    }else{
                        Group{
                            TextField("Event Name", text: $eventName)
                                .foregroundColor(AssetManager.textColor)
                            Divider().padding(.bottom, 10)
                            
                            TextField("Location", text: $location)
                                .foregroundColor(AssetManager.textColor)
                            Divider().padding(.bottom, 10)
                            
                            TextField("Link (optional, include full url)", text: $link)
                                .foregroundColor(AssetManager.textColor)
                            Divider().padding(.bottom, 10)
                            
                            DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute]).foregroundColor(AssetManager.textColor)
                            
                            DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute]).foregroundColor(AssetManager.textColor)
                        }
                    }
                    
                    
                    // MARK: Button
                    if(loadInProgress){
                        LoadingSpinner()
                    }else{
                        Button(action: {
                            uploadPost()
                        }){
                            Text("Post")
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
    }
}

