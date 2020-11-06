//
//  CreateEventView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-05.
//  Copyright © 2020 ivy. All rights reserved.
//
//  New Event
//  TODO: input check -> give feedback
//

import SwiftUI
import SDWebImageSwiftUI


struct CreateEventView: View {
    
    @ObservedObject private var createEventVM: CreateEventViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var visualPick = 0
    @State private var textInput = ""
    @State private var eventName = ""
    @State private var location = ""
    @State private var link = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var editingMode = false
    var editModeType = 0
    
    
    // Check input before posting
    func inputOk() -> Bool{ //TODO: check date
        return (!textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    
    
    init(_ alreadyExistingEvent: Event_new? = nil){
        self.createEventVM = CreateEventViewModel(event: alreadyExistingEvent)
        self.editingMode = alreadyExistingEvent != nil
    }
    
    
    

    // MARK: View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                if(self.editingMode){

                    Text("Edit Event").font(.largeTitle)
                        .foregroundColor(AssetManager.textColor)
                        .padding(.bottom, 10)
                    
                    
                    Text("All values will be overwritten! (I.e. You'll have to fill out all the fields again, only comments & going users will be kept.)")
                        .foregroundColor(AssetManager.ivyNotificationRed)
                        .padding(.bottom, 10)
                }
                else {
                    Text("Create Event").font(.largeTitle)
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
                    

                    Group{
                        TextField("Event Name", text: $eventName)
                            .foregroundColor(AssetManager.textColor)
                        Divider().padding(.bottom, 10)
                        
                        TextField("Description", text: $textInput).foregroundColor(AssetManager.textColor)
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
                    
                    
                    
                    // MARK: Button
                    if(createEventVM.loadInProgress){
                        LoadingSpinner()
                    }else{
                        Button(action: {
                            if (self.editingMode) {
                                createEventVM.uploadEdittedEvent(
                                    text: self.textInput,
                                    eventName: self.eventName,
                                    startDate: self.startDate,
                                    endDate: self.endDate,
                                    link: self.link,
                                    location: self.location,
                                    image: self.inputImage)
                            } else {
                                createEventVM.uploadNewEvent(
                                    text: self.textInput,
                                    eventName: self.eventName,
                                    startDate: self.startDate,
                                    endDate: self.endDate,
                                    link: self.link,
                                    location: self.location,
                                    image: self.inputImage)
                            }
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
        
        // Dismiss View when VM gives the signal
        .onReceive(self.createEventVM.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

