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
    var thisUser: User
    @State private var typePick = 0
    @State private var visualPick = 0
    @State private var textInput = ""
    @State private var eventName = ""
    @State private var location = ""
    @State private var link = ""
    @State private var pinnedName: String?
    @State private var pinnedId: String?
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var pinned_ids = [String]()
    @State private var pinned_names = [String]()
    @Environment(\.presentationMode) var presentationMode
    
    
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
    
    func loadPinnedNames(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).getDocuments { (querSnapshot, error) in
            if let querSnap = querSnapshot{
                print("inside")
                for doc in querSnap.documents{
                    if let id = doc.get("id") as? String, let nam = doc.get("name") as? String{
                        self.pinned_ids.append(id)
                        self.pinned_names.append(nam)
                        print("adding: "+nam)
                    }
                }
            }
        }
    }
    
    func uploadPost(){
        var newPost = [String: Any]()
        
        // MARK: Post Declaration
        if(typePick == 0){
            newPost["id"] = UUID.init().uuidString
            newPost["uni_domain"] = Utils.getCampusUni()
            newPost["author_id"] = thisUser.id
            newPost["author_name"] = thisUser.name
            newPost["author_is_organization"] = thisUser.is_organization
            newPost["is_event"] = false
            newPost["main_feed_visible"] = true
            newPost["creation_millis"] = Int(Utils.getCurrentTimeInMillis())
            newPost["creation_platform"] = "iOS"
            newPost["text"] = textInput
            newPost["pinned_name"] = pinnedName
            newPost["pinned_id"] = pinnedId
            newPost["views_id"] = [String]()
            
            
            
        // MARK: Event Declaration
        }else{
            newPost["id"] = UUID.init().uuidString
            newPost["name"] = eventName
            newPost["uni_domain"] = Utils.getCampusUni()
            newPost["is_event"] = true
            newPost["author_id"] = thisUser.id
            newPost["author_name"] = thisUser.name
            newPost["author_is_organization"] = thisUser.is_organization
            newPost["main_feed_visible"] = true
            newPost["creation_millis"] = Int(Utils.getCurrentTimeInMillis())
            newPost["creation_platform"] = "iOS"
            newPost["text"] = textInput
            newPost["views_id"] = [String]()
            newPost["going_ids"] = [String]()
            newPost["start_millis"] = Int(startDate.timeIntervalSince1970*1000)
            newPost["end_millis"] = Int(endDate.timeIntervalSince1970*1000)
            newPost["is_active"] = true
            newPost["is_featured"] = false
            newPost["link"] = link
            newPost["location"] = location
            if(visualPick == 1 && image != nil){
                newPost["visual"] = Utils.postFullVisualPath(postId: newPost["id"] as! String)
            }else{
                newPost["visual"] = "nothing"
            }
        }
        
        
        // MARK: Visual & Data Upload
        if(visualPick == 1 && image != nil){
            newPost["visual"] = Utils.postFullVisualPath(postId: newPost["id"] as! String)
        }else{
            newPost["visual"] = "nothing"
        }
        
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(newPost["id"] as! String).setData(newPost){error in
            if error == nil{
                if(self.visualPick == 1 && self.image != nil){
                    self.storageRef.child(newPost["visual"] as! String).putData((self.inputImage?.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                        if(error != nil){
                            print(error)
                        }
                        self.storageRef.child(Utils.postPreviewImagePath(postId: newPost["id"] as! String)).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                            if(error1 != nil){
                                print(error1)
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }else{
                    //TODO: finish
                }
            }
        }
    }
    
    
    
    
    
    
    
    // MARK: View
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                // MARK: Type
                HStack{
                    Text("Type").font(.system(size: 25))
                    Spacer()
                }
                Picker("Type", selection: $typePick) {
                    Text("Post").tag(0)
                    Text("Event").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 10)
                
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
                            image?.resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 10)
                }
                
                
                // MARK: Text
                TextField("Text", text: $textInput)
                Divider().padding(.bottom, 10)
                
                
                // MARK: Pinned
                if(typePick == 0){
                    Group{
                        DropDownMenu(
                            selected: $pinnedName,
                            list: self.pinned_names,
                            hint: "Pinned Event",
                            hintColor: Color.gray,
                            expandedHeight: 200
                        )
                        .padding(.bottom, 10)
                    }
                    
                    
                // MARK: Event Fields
                }else{
                    Group{
                        TextField("Event Name", text: $eventName)
                        Divider().padding(.bottom, 10)
                        
                        TextField("Location", text: $location)
                        Divider().padding(.bottom, 10)
                        
                        TextField("Link (optional)", text: $link)
                        Divider().padding(.bottom, 10)
                        
                        DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        
                        DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                
                // MARK: Button
                Button(action: {
                    self.uploadPost()
                }){
                    Text("Post")
                }
                .disabled(!inputOk())
                .buttonStyle(StandardButtonStyle(disabled: !inputOk()))
                
                
                
            }
        }
        .padding()
    }
}

