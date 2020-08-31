//
//  EventScreenView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct EventScreenView: View {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    @ObservedObject var eventVM: EventItemViewModel
    @ObservedObject var commentListVM: CommentListViewModel
    @State var editEventPresented = false
    @State var imageUrl = ""
    @State var authorUrl = ""
    @State var commentAuthorUrl = ""
    @State var selection: Int? = nil
    @State var commentAddImage = false
    @State var commentInput = ""
    @State private var isShareSheetShowing = false
    @State private var showingCalendarAlert = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State var loadInProgress = false
    private var notificationSender = NotificationSender()
    
    
    // MARK: Functions
    func addToViewIds(){
        if(Auth.auth().currentUser != nil && eventVM.event.id != nil){
            db.collection("universities").document(eventVM.event.uni_domain).collection("posts").document(eventVM.event.id!).updateData([
                "views_id": FieldValue.arrayUnion([Auth.auth().currentUser?.uid ?? ""])
            ])
        }
    }
    
    func sendCommentNotification(){
        if(Auth.auth().currentUser!.uid != eventVM.event.author_id){
            db.collection("users").document(eventVM.event.author_id).getDocument { (docSnap, err) in
                if err != nil{
                    print("Error loading post author for comment notification.")
                    return
                }
                if let doc = docSnap{
                    let author = User()
                    author.docToObject(doc: doc)
                    self.notificationSender.sendPushNotification(to: author.messaging_token, title: Utils.getThisUserName() + " commented on your event.", body: Utils.getThisUserName() + " commented on " + self.eventVM.event.name, conversationID: "")
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func uploadComment(){
        loadInProgress = true
        let newComment = Comment()
        newComment.id = UUID.init().uuidString
        if(commentAddImage){
            newComment.setInitialData(id: newComment.id!, authorId: Auth.auth().currentUser!.uid, authorIsOrg: Utils.getIsThisUserOrg(), authorNam: Utils.getThisUserName(), txt: Utils.commentVisualPath(postId: eventVM.event.id ?? "", commentId: newComment.id!), typ: 2, uniDom: eventVM.event.uni_domain, creaMil: Int(Utils.getCurrentTimeInMillis()))
            
            if(image != nil && inputImage != nil){ //upload image first to make sure it's ready to display once we refresh
                self.storageRef.child(newComment.text).putData((self.inputImage?.jpegData(compressionQuality: 0.4))!, metadata: nil){ (metadat, error) in
                    if(error != nil){
                        print(error!.localizedDescription)
                        return
                    }
                    
                    self.db.collection("universities").document(self.eventVM.event.uni_domain).collection("posts").document(self.eventVM.event.id ?? "").collection("comments").document().setData(newComment.getMap()){error in
                        if(error != nil){
                            print("Error uploading new comment.")
                            return
                        }
                        
                        self.commentInput = "" //reset comment layout once succesfully added
                        self.commentAddImage = false
                        self.image = nil
                        self.loadInProgress = false
                        self.commentListVM.refresh() //refresh to show the new comment right away
                        self.sendCommentNotification()
                    }
                }
            }
        }else{
            newComment.setInitialData(id: newComment.id!, authorId: Auth.auth().currentUser!.uid, authorIsOrg: Utils.getIsThisUserOrg(), authorNam: Utils.getThisUserName(), txt: commentInput, typ: 1, uniDom: eventVM.event.uni_domain, creaMil: Int(Utils.getCurrentTimeInMillis()))
            db.collection("universities").document(eventVM.event.uni_domain).collection("posts").document(eventVM.event.id ?? "").collection("comments").document().setData(newComment.getMap()){error in
                if(error != nil){
                    print("Error uploading new comment.")
                    return
                }
                
                self.commentInput = "" //reset comment layout once succesfully added
                self.commentAddImage = false
                self.image = nil
                self.loadInProgress = false
                self.commentListVM.refresh()
                self.sendCommentNotification()
            }
        }
    }
    
    init(eventVM: EventItemViewModel){
        self.eventVM = eventVM
        commentListVM = CommentListViewModel(uniDom: eventVM.event.uni_domain, postId: eventVM.event.id ?? "")
    }
    
    
    
    
    
    
    
    // MARK: View
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                
                //MARK: Image
                if (!eventVM.event.visual.isEmpty && eventVM.event.visual != "nothing") {
                    WebImage(url: URL(string: self.imageUrl))
                        .resizable()
                        .placeholder(AssetManager.logoWhite)
                        .background(AssetManager.ivyLightGrey)
                        .aspectRatio(contentMode: .fit)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(self.eventVM.event.visual).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading featured image.")
                                    return
                                }
                                self.imageUrl = "\(url!)"
                            }
                    }
                }
                
                
                VStack(alignment: .leading){
                    //MARK: Author Row
                    ZStack{
                        HStack(){
                            WebImage(url: URL(string: authorUrl))
                                .resizable()
                                .placeholder(Image(systemName: "person.crop.circle.fill"))
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .onAppear(){
                                    let storage = Storage.storage().reference()
                                    storage.child(Utils.userPreviewImagePath(userId: self.eventVM.event.author_id)).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading event image.")
                                            return
                                        }
                                        self.authorUrl = "\(url!)"
                                    }
                            }
                            Text(self.eventVM.event.author_name)
                            Spacer()
                        }
                        .onTapGesture {
                            self.selection = 1
                        }
                        .padding(.bottom)
                        
                        
                        NavigationLink(
                            destination: OrganizationProfile(uid: eventVM.event.author_id)
                                .navigationBarTitle("Profile"),
                            tag: 1,
                            selection: self.$selection) {
                                EmptyView()
                        }
                        
//                        if (eventVM.event.author_is_organization) {
//                            NavigationLink(
//                                destination: OrganizationProfile(uid: eventVM.event.author_id)
//                                    .navigationBarTitle("Profile"),
//                                tag: 1,
//                                selection: self.$selection) {
//                                    EmptyView()
//                            }
//                        } else {
//                            NavigationLink(
//                                destination: StudentProfile(uid: eventVM.event.author_id)
//                                    .navigationBarTitle("Profile"),
//                                tag: 1,
//                                selection: self.$selection) {
//                                    EmptyView()
//                            }
//                        }
                    }
                    
                    //MARK: Time Row
                    HStack{
                        Image(systemName: "clock.fill")
                        Text(Utils.getEventDate(millis:eventVM.event.start_millis) + " - " + Utils.getEventDate(millis:eventVM.event.end_millis))
                        Spacer()
                    }
                    
                    //MARK: Location Row
                    HStack{
                        Image(systemName: "location.fill")
                        Text(eventVM.event.location)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    //MARK: Text
                    Text(eventVM.event.text)
                }
                .padding(.leading)
                .padding(.trailing)
                
                
                
                //MARK: Going
                HStack{
                    Text("Who's Going:")
                    Spacer()
                }.padding(.horizontal).padding(.top, 20)
                
                if(eventVM.event.going_ids.count < 1){
                    Text("Nobody's going to this event yet.").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
                } else {
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(eventVM.event.going_ids, id: \.self) { currentId in
                                ZStack{
                                    PersonCircleView(personId: currentId)
                                        .onTapGesture{
                                            self.selection = self.eventVM.event.going_ids.firstIndex(of: currentId)! + 2 //needed to have a unique tag for each going person, so we use their index in the array with an offset
                                    }
                                    NavigationLink(
                                        destination: OrganizationProfile(uid: currentId)
                                            .navigationBarTitle("Profile"),
                                        tag: self.eventVM.event.going_ids.firstIndex(of: currentId)! + 2,
                                        selection: self.$selection) {
                                            EmptyView()
                                    }
                                    
                                    
                                }
                                .padding(.leading, 10)
                            }
                        }
                        .padding(.top, 10).padding(.bottom, 30)
                    }
                    .frame(width: UIScreen.screenWidth)
                }
            }
            
            
            
            //MARK: Button Row
            HStack(alignment: .center){
                
                Spacer()
                //MARK: Share
                Button(action: {
                    self.isShareSheetShowing.toggle()
                    let av = UIActivityViewController(activityItems: ["EVENT: \(self.eventVM.event.name), from: \(Utils.getEventDate(millis:self.eventVM.event.start_millis)) to: \(Utils.getEventDate(millis:self.eventVM.event.end_millis)), at: \(self.eventVM.event.location), description: \(self.eventVM.event.text), link: \(self.eventVM.event.link)"], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                }) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 10)
                }
                Spacer()
                
                
                //MARK: Calendar
                Button(action: {
                    self.showingCalendarAlert.toggle()
                    CalendarUtil.addToCalendar(startDate: Date(timeIntervalSince1970: TimeInterval(self.eventVM.event.start_millis/1000)), endDate: Date(timeIntervalSince1970: TimeInterval(self.eventVM.event.end_millis/1000)), eventName: self.eventVM.event.name, extras: "Location: \(self.eventVM.event.location), Link: \(self.eventVM.event.link), Description: \(self.eventVM.event.text)")
                }) {
                    Image(systemName: "calendar.badge.plus").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen)
                }
                .alert(isPresented: $showingCalendarAlert){
                    Alert(title: Text("Event Added"), message: Text("\(self.eventVM.event.name) is now in your default calendar"), dismissButton: .default(Text("OK")))
                }
                Spacer()
                
                //MARK: Link
                if(Utils.verifyUrl(urlString: eventVM.event.link)){ //if link is valid, only then show the link button
                    Button(action: {
                        if let url = URL(string: self.eventVM.event.link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "link").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 5)
                    }
                    Spacer()
                }
                
                
                //MARK: Going
                if(Auth.auth().currentUser != nil && !Utils.getIsThisUserOrg()){
                    Button(action: {
                        if(self.eventVM.event.going_ids.contains(Auth.auth().currentUser!.uid)){
                            self.eventVM.removeFromGoing()
                        }else{
                            self.eventVM.addToGoing()
                        }
                    }) {
                        Image(systemName: self.eventVM.thisUserGoing ? "checkmark.circle.fill" : "checkmark.circle").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 5)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            
            
            
            
            // MARK: Edit Event
            if(Auth.auth().currentUser != nil && eventVM.event.author_id == Auth.auth().currentUser!.uid){ //viewer is also author
                Button(action: {
                    self.editEventPresented.toggle()
                }) {
                    Text("Edit").foregroundColor(AssetManager.ivyGreen)
                        .sheet(isPresented: $editEventPresented, onDismiss: {
                            //TODO: refresh on dismiss
                        }) {
                            CreatePostView(typePick: 1, alreadyExistingEvent: self.eventVM.event, alreadyExistingPost: Post(), editingMode: true)
                    }
                }
                .padding(.top, 30)
            }
            
            
            
            
            
            
            
           // MARK: Comments
            HStack{
                Text("Comments").font(.system(.title)).multilineTextAlignment(.leading).padding(.top, 30).padding(.leading)
                Spacer()
            }
            
            
            // MARK: Comment Input
            if(Auth.auth().currentUser != nil){ //only logged in users can comment
                ZStack{
                    HStack(alignment: .center){
                        
                        // MARK: Comment Author
                        WebImage(url: URL(string: commentAuthorUrl))
                            .resizable()
                            .placeholder(Image(systemName: "person.crop.circle.fill"))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                storage.child(Utils.userPreviewImagePath(userId: Auth.auth().currentUser?.uid ?? "")).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading comment author image.")
                                        return
                                    }
                                    self.commentAuthorUrl = "\(url!)"
                                }
                        }
                        
                        
                        
                        // MARK: Comment Text/Image
                        if(commentAddImage){
                            if(image != nil){
                                VStack(alignment: .center){
                                    image?.resizable().aspectRatio(contentMode: .fit)
                                }
                            }else{
                                Spacer()
                            }
                        }else{
                            VStack(alignment: .leading, spacing: 0){
                                TextField("Your Comment", text: self.$commentInput)
                                Divider()
                            }
                        }
                        
                        
                        
                        // MARK: Image Button
                        Button(action: {
                            self.commentAddImage.toggle()
                            if(self.commentAddImage){
                                self.showingImagePicker = true
                            }
                        }){
                            Image(systemName: commentAddImage ? "xmark.circle" : "photo.fill").foregroundColor(AssetManager.ivyGreen).font(.system(size: 25))
                                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                                    ImagePicker(image: self.$inputImage)
                            }
                        }
                        
                        
                        //MARK: Send Button
                        Button(action: {
                            self.uploadComment()
                        }){
                            Image(systemName: "paperplane.fill" ).foregroundColor((loadInProgress || (commentInput.isEmpty && !commentAddImage) ||  (image == nil && commentAddImage)) ? AssetManager.ivyLightGrey : AssetManager.ivyGreen).font(.system(size: 25))
                        }
                        .disabled(loadInProgress || (commentInput.isEmpty && !commentAddImage) ||  (image == nil && commentAddImage))
                        
                    }
                    .padding()
                    .background(AssetManager.ivyBackgroundGrey)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    
                    if(loadInProgress){
                        LoadingSpinner().frame(width: 50, height: 50, alignment: .center)
                    }
                }
                .padding()
            }
            
            
            
            
            // MARK: Comment List
            if(self.commentListVM.commentVMs.count > 0){
                ForEach(commentListVM.commentVMs){ commentVM in
                    ZStack{
                        VStack{
                            CommentView(commentVM: commentVM).padding(.horizontal, 10)
                                .onTapGesture {
                                    self.selection = commentVM.selectionId
                            }
                            Divider().padding(.vertical, 20)
                        }
                        
                        NavigationLink(
                            destination: OrganizationProfile(uid: commentVM.comment.author_id)
                                .navigationBarTitle("Profile"),
                            tag: commentVM.selectionId ,
                            selection: self.$selection) {
                                EmptyView()
                        }
                    }
                }
            }else{
                Text("No Comments yet.").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
            }
            
            
            
            
            
            
            
            
            //MARK: onAppear
        }
        .onAppear(perform: {
            self.addToViewIds()
        })
        .keyboardAdaptive()
            .onTapGesture { //hide keyboard when background tapped
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
}




