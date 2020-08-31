//
//  PostScreen.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PostScreen: View {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    @ObservedObject var postVM: HomePostViewModel
    @ObservedObject var commentListVM: CommentListViewModel
    var pinnedEventVM: EventItemViewModel
    @State var commentAddImage = false
    @State var imageUrl = ""
    @State var authorUrl = ""
    @State var commentInput = ""
    @State var commentAuthorUrl = ""
    @State var loadInProgress = false
    @State private var selection : Int? = nil
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var editPostPresented = false
    private var notificationSender = NotificationSender()
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    
    // MARK: Functions
    func addToViewIds(){
        if(Auth.auth().currentUser != nil && postVM.post.id != nil){
            db.collection("universities").document(postVM.post.uni_domain).collection("posts").document(postVM.post.id!).updateData([
                "views_id": FieldValue.arrayUnion([Auth.auth().currentUser?.uid ?? ""])
            ])
        }
    }
    
    
    func sendCommentNotification(){
        if(Auth.auth().currentUser!.uid != postVM.post.author_id){
            db.collection("users").document(postVM.post.author_id).getDocument { (docSnap, err) in
                if err != nil{
                    print("Error loading post author for comment notification.")
                    return
                }
                if let doc = docSnap{
                    let author = User()
                    author.docToObject(doc: doc)
                    self.notificationSender.sendPushNotification(to: author.messaging_token, title: Utils.getThisUserName() + " commented on your post.", body: Utils.getThisUserName() + " commented on: " + self.postVM.post.text, conversationID: "")
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
            newComment.setInitialData(id: newComment.id!, authorId: Auth.auth().currentUser!.uid, authorIsOrg: Utils.getIsThisUserOrg(), authorNam: Utils.getThisUserName(), txt: Utils.commentVisualPath(postId: postVM.post.id ?? "", commentId: newComment.id!), typ: 2, uniDom: postVM.post.uni_domain, creaMil: Int(Utils.getCurrentTimeInMillis()))
            
            if(image != nil && inputImage != nil){ //upload image first to make sure it's ready to display once we refresh
                self.storageRef.child(newComment.text).putData((self.inputImage?.jpegData(compressionQuality: 0.4))!, metadata: nil){ (metadat, error) in
                    if(error != nil){
                        print(error!.localizedDescription)
                        return
                    }
                    
                    self.db.collection("universities").document(self.postVM.post.uni_domain).collection("posts").document(self.postVM.post.id ?? "").collection("comments").document().setData(newComment.getMap()){error in
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
            newComment.setInitialData(id: newComment.id!, authorId: Auth.auth().currentUser!.uid, authorIsOrg: Utils.getIsThisUserOrg(), authorNam: Utils.getThisUserName(), txt: commentInput, typ: 1, uniDom: postVM.post.uni_domain, creaMil: Int(Utils.getCurrentTimeInMillis()))
            db.collection("universities").document(postVM.post.uni_domain).collection("posts").document(postVM.post.id ?? "").collection("comments").document().setData(newComment.getMap()){error in
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
    
    
    init(postVM: HomePostViewModel){
        self.postVM = postVM
        pinnedEventVM = EventItemViewModel(event: postVM.pinnedEvent)
        commentListVM = CommentListViewModel(uniDom: postVM.post.uni_domain, postId: postVM.post.id ?? "")
    }
    
    
    
    
    
    // MARK: View
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                //MARK: Image
                if(postVM.post.visual != "" && postVM.post.visual != "nothing"){
                    WebImage(url: URL(string: self.imageUrl))
                        .resizable()
                        .placeholder(AssetManager.logoWhite)
                        .background(AssetManager.ivyLightGrey)
                        .aspectRatio(contentMode: .fit)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(self.postVM.post.visual).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading post screen image.")
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
                                    storage.child(Utils.userPreviewImagePath(userId: self.postVM.post.author_id)).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading post screen author image.")
                                            return
                                        }
                                        self.authorUrl = "\(url!)"
                                    }
                            }
                            Text(self.postVM.post.author_name)
                            Spacer()
                        }
                        .onTapGesture {
                            self.selection = 1
                        }
                        
                        
                        NavigationLink(
                            destination: OrganizationProfile(uid: postVM.post.author_id)
                                .navigationBarTitle("Profile"),
                            tag: 1,
                            selection: self.$selection) {
                                EmptyView()
                        }
                        
//                        if (postVM.post.author_is_organization) {
//                            NavigationLink(
//                                destination: OrganizationProfile(uid: postVM.post.author_id)
//                                    .navigationBarTitle("Profile"),
//                                tag: 1,
//                                selection: self.$selection) {
//                                    EmptyView()
//                            }
//                        } else {
//                            NavigationLink(
//                                destination: StudentProfile(uid: postVM.post.author_id)
//                                    .navigationBarTitle("Profile"),
//                                tag: 1,
//                                selection: self.$selection) {
//                                    EmptyView()
//                            }
//                        }
                    }.padding(.bottom, 10)
                    
                    // MARK: Pinned Layout
                    if(self.postVM.post.pinned_id != "" && self.postVM.post.pinned_id != "nothing"){
                        HStack{
                            Image(systemName: "pin.fill").rotationEffect(Angle(degrees: -45))
                            ZStack{
                                Text(self.postVM.post.pinned_name).foregroundColor(AssetManager.ivyGreen).padding(.top, 5)
                                    .onTapGesture {
                                        self.selection = 2
                                }
                                NavigationLink(destination: EventScreenView(eventVM: pinnedEventVM).navigationBarTitle(postVM.post.pinned_name), tag: 2, selection: self.$selection){
                                    EmptyView()
                                }
                                Spacer()
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    // MARK: Text
                    Text(postVM.post.text).multilineTextAlignment(.leading)
                    
                }
                .padding(.horizontal)
                
                
                
                
                // MARK: Edit Post
                if(Auth.auth().currentUser != nil && postVM.post.author_id == Auth.auth().currentUser!.uid){ //viewer is also author
                    Button(action: {
                        self.editPostPresented.toggle()
                    }) {
                        Text("Edit").foregroundColor(AssetManager.ivyGreen)
                            .sheet(isPresented: $editPostPresented, onDismiss: {
                                //TODO: refresh on dismiss
                            }) {
                                CreatePostView(typePick: 0, alreadyExistingEvent: Event(), alreadyExistingPost: self.postVM.post, editingMode: true)
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




            }

            // MARK: onAppear
        }
        .onAppear(){
            self.addToViewIds()
        }
        .keyboardAdaptive()
            .onTapGesture { //hide keyboard when background tapped
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
}

