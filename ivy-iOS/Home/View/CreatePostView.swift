//
//  CreatePostView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase
import PhotoLibraryPicker

struct CreatePostView: View {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    @ObservedObject private var createPostRepo = CreatePostRepo()
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
    func sendNotification(){ //send notifications to all members (if this user is org)
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (docSnap, err) in
            if err != nil{
                print("Can't send notifications, failed to get user profile.")
                return
            }
            if let doc = docSnap{
                let thisUser = User()
                thisUser.docToObject(doc: doc)
                if thisUser.member_ids.count > 0{
                    let memberCount = thisUser.member_ids.count
                    var index = 0
                    for memberId in thisUser.member_ids{
                        index = index + 1
                        self.db.collection("users").document(memberId).getDocument { (docSnap1, error1) in
                            if error1 != nil{
                                print("Failed to get member to send notification to.")
                                return
                            }
                            if let doc1 = docSnap1{
                                let member = User()
                                member.docToObject(doc: doc1)
                                
                                if(!self.editingMode){ //the org was creating a new post
                                    if(self.typePick == 0){ //notifying about post
                                        self.notificationSender.sendPushNotification(to: member.messaging_token, title: thisUser.name+" added a new post.", body: self.textInput, conversationID: "")
                                    }else{ //notifying about event
                                        self.notificationSender.sendPushNotification(to: member.messaging_token, title: thisUser.name+" added a new event.", body: self.eventName, conversationID: "")
                                    }
                                }else{ //the org was editing an existing post
                                    if(self.typePick == 0){ //notifying about post
                                        self.notificationSender.sendPushNotification(to: member.messaging_token, title: thisUser.name+" made changes to their post.", body: self.textInput, conversationID: "")
                                    }else{ //notifying about event
                                        self.notificationSender.sendPushNotification(to: member.messaging_token, title: thisUser.name+" mad changes to their event.", body: self.eventName, conversationID: "")
                                    }
                                }

                                if index >= memberCount{
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }else{
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
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
    
    func uploadPost(){
        loadInProgress = true
        var newPost = [String: Any]()
        
        // MARK: Editing Existing Declaration
        if(editingMode){
            if(typePick == 0){ //editing post
                alreadyExistingPost.text = textInput
                if let pinName = pinnedName{
                    alreadyExistingPost.pinned_name = pinName
                    alreadyExistingPost.pinned_id = createPostRepo.pinnedIds[createPostRepo.pinnedNames.firstIndex(of: pinName)!]
                }else{
                    alreadyExistingPost.pinned_name = ""
                    alreadyExistingPost.pinned_id = ""
                }
            }else{ //editing event
                alreadyExistingEvent.text = textInput
                alreadyExistingEvent.name = eventName
                alreadyExistingEvent.start_millis = Int(startDate.timeIntervalSince1970*1000)
                alreadyExistingEvent.end_millis = Int(endDate.timeIntervalSince1970*1000)
                alreadyExistingEvent.link = link
                alreadyExistingEvent.location = location
            }
            
            
            
        // MARK: New Post Declaration
        }else{
            newPost["id"] = UUID.init().uuidString
            newPost["uni_domain"] = Utils.getCampusUni()
            newPost["author_id"] = Auth.auth().currentUser?.uid ?? ""
            newPost["author_name"] = Utils.getThisUserName()
            newPost["author_is_organization"] = Utils.getIsThisUserOrg()
            newPost["creation_millis"] = Int(Utils.getCurrentTimeInMillis())
            newPost["creation_platform"] = "iOS"
            newPost["text"] = textInput
            newPost["main_feed_visible"] = true
            
            if(typePick == 0){
                newPost["is_event"] = false
                if let pinName = pinnedName{
                    newPost["pinned_name"] = pinName
                    newPost["pinned_id"] = createPostRepo.pinnedIds[createPostRepo.pinnedNames.firstIndex(of: pinName)!]
                }else{
                    newPost["pinned_name"] = ""
                    newPost["pinned_id"] = ""
                }
                newPost["views_id"] = [String]()
                
                
            // MARK: New Event Declaration
            }else{
                newPost["name"] = eventName
                newPost["is_event"] = true
                newPost["views_id"] = [String]()
                newPost["going_ids"] = [String]()
                newPost["start_millis"] = Int(startDate.timeIntervalSince1970*1000)
                newPost["end_millis"] = Int(endDate.timeIntervalSince1970*1000)
                newPost["is_active"] = true
                newPost["is_featured"] = false
                newPost["link"] = link
                newPost["location"] = location
            }
        }

        
        
        // MARK: Visual
        if(visualPick == 1 && image != nil){
            if(editingMode){
                alreadyExistingPost.visual = Utils.postFullVisualPath(postId: alreadyExistingPost.id ?? "") //lazy...
                alreadyExistingEvent.visual = Utils.postFullVisualPath(postId: alreadyExistingEvent.id ?? "")
            }else{
                newPost["visual"] = Utils.postFullVisualPath(postId: newPost["id"] as! String)
            }
            
        }else{
            if(editingMode){
                alreadyExistingPost.visual = "nothing"
                alreadyExistingEvent.visual = "nothing"
            }else{
                newPost["visual"] = "nothing"
            }
        }
        
        
        
        // MARK: Data Upload
        if(editingMode){
            if(typePick == 0){ //post
                db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(alreadyExistingPost.id ?? "").setData(alreadyExistingPost.getMap()){error in
                    if error == nil{
                        if(self.visualPick == 1 && self.image != nil){
                            self.storageRef.child(self.alreadyExistingPost.visual ?? "").putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                                if(error != nil){
                                    print(error!)
                                }
                                self.storageRef.child(Utils.postPreviewImagePath(postId: self.alreadyExistingPost.id ?? "" )).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                                    if(error1 != nil){
                                        print(error1!)
                                    }
                                    if Utils.getIsThisUserOrg(){
                                        self.sendNotification()
                                    }else{
                                       self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }else{
                            if Utils.getIsThisUserOrg(){
                                self.sendNotification()
                            }else{
                               self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }else{ //event
                db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(alreadyExistingEvent.id ?? "").setData(alreadyExistingEvent.getMap()){error in
                    if error == nil{
                        if(self.visualPick == 1 && self.image != nil){
                            self.storageRef.child(self.alreadyExistingEvent.visual ?? "").putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                                if(error != nil){
                                    print(error!)
                                }
                                self.storageRef.child(Utils.postPreviewImagePath(postId: self.alreadyExistingEvent.id ?? "" )).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                                    if(error1 != nil){
                                        print(error1!)
                                    }
                                    if Utils.getIsThisUserOrg(){
                                        self.sendNotification()
                                    }else{
                                       self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }else{
                            if Utils.getIsThisUserOrg(){
                                self.sendNotification()
                            }else{
                               self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            
            //MARK: Non-Edited
        }else{
            db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(newPost["id"] as! String).setData(newPost){error in
                if error == nil{
                    if(self.visualPick == 1 && self.image != nil){
                        self.storageRef.child(newPost["visual"] as! String).putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                            if(error != nil){
                                print(error!)
                            }
                            self.storageRef.child(Utils.postPreviewImagePath(postId: newPost["id"] as! String)).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                                if(error1 != nil){
                                    print(error1!)
                                }
                                if Utils.getIsThisUserOrg(){
                                    self.sendNotification()
                                }else{
                                   self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }else{
                        if Utils.getIsThisUserOrg(){
                            self.sendNotification()
                        }else{
                           self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    init(typePick: Int, alreadyExistingEvent: Event, alreadyExistingPost: Post, editingMode: Bool){
        self.typePick = typePick
        self.alreadyExistingEvent = alreadyExistingEvent
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
                    }else{
                        Text("Edit Event").font(.largeTitle).padding(.bottom, 10)
                    }
                    Text("All values will be overwritten! (I.e. You'll have to fill out all the fields again, only comments & going users will be kept.)").foregroundColor(AssetManager.ivyNotificationRed).padding(.bottom, 10)
                }else{
                    if(typePick == 0){
                        Text("Create Post").font(.largeTitle).padding(.bottom, 10)
                    }else{
                        Text("Create Event").font(.largeTitle).padding(.bottom, 10)
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
                    Text("Visual").font(.system(size: 25))
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
                    TextField("Text", text: $textInput)
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
                            Divider().padding(.bottom, 10)
                            
                            TextField("Location", text: $location)
                            Divider().padding(.bottom, 10)
                            
                            TextField("Link", text: $link)
                            Divider().padding(.bottom, 10)
                            
                            DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            
                            DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                    
                    
                    // MARK: Button
                    if(loadInProgress){
                        LoadingSpinner()
                    }else{
                        Button(action: {
                            self.uploadPost()
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
        .padding()
        .keyboardAdaptive()
    }
}


