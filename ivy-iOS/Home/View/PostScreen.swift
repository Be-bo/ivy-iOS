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
    @ObservedObject var postVM: PostViewModel
    @ObservedObject var commentListVM: CommentListViewModel
    var pinnedEventVM: EventItemViewModel
    @State var commentAddImage = false
    @State var imageUrl = ""
    @State var authorUrl = ""
    @State var commentInput = ""
    @State var commentAuthorUrl = ""
    @State var loadInProgress = false
    @State private var showReportAlert = false
    @State private var selection : Int? = nil
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var editPostPresented = false
    @State private var showNotLoggedInAlert = false
    private var notificationSender = NotificationSender()
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    
    // MARK: Functions
    func reportPost(){
        var newReport = [String: Any]()
        let id = UUID.init().uuidString
        newReport["id"] = UUID.init().uuidString
        newReport["type"] = "post"
        newReport["target_id"] = postVM.post.id
        newReport["uni_domain"] = postVM.post.uni_domain
        newReport["creation_millis"] = Int(Utils.getCurrentTimeInMillis())
        db.collection("reports").document(id).setData(newReport)
    }
    
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
                    var author = User()
                    do { try author = doc.data(as: User.self)! }
                    catch { print("Could not load User for UserRepo: \(error)") }
                    
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
    
    
    init(postVM: PostViewModel){
        self.postVM = postVM
        pinnedEventVM = EventItemViewModel(event: postVM.pinnedEvent)
        commentListVM = CommentListViewModel(uniDom: postVM.post.uni_domain, postId: postVM.post.id ?? "")
    }
    
    
    
    
    
    // MARK: View
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                //MARK: Image
                if (!postVM.post.visual.isEmpty && postVM.post.visual != "nothing") {
                    FirebaseImage(
                        path: self.postVM.post.visual,
                        placeholder: AssetManager.logoGreen,
                        width: UIScreen.screenWidth,
                        height: UIScreen.screenWidth,
                        shape: Rectangle()
                    )
                }
                
                
                
                VStack(alignment: .leading){
                    //MARK: Author Row
                    ZStack{
                        HStack(){
                            
                            FirebaseImage(
                                path: Utils.userPreviewImagePath(userId: self.postVM.post.author_id),
                                placeholder: AssetManager.logoGreen,
                                width: 40,
                                height: 40,
                                shape: RoundedRectangle(cornerRadius: 20)
                            )
                            
                            Text(self.postVM.post.author_name).foregroundColor(AssetManager.ivyGreen)
                            Spacer()
                        }
                        .onTapGesture {
                            self.selection = 1
                        }
                        
                        if(Auth.auth().currentUser != nil){
                            NavigationLink(
                                destination: UserProfile(uid: postVM.post.author_id)
                                    .navigationBarTitle("Profile"),
                                tag: 1,
                                selection: self.$selection) {
                                EmptyView()
                            }
                        }else{
                            Button(action: {
                                self.showNotLoggedInAlert = true
                            }) {
                                HStack{
                                    Text("invisible button right here").hidden()
                                    Spacer()
                                }
                            }
                            .alert(isPresented: $showNotLoggedInAlert) {
                                Alert(title: Text("Login Required"), message: Text("Log in to see this user's events and posts!"), dismissButton: .default(Text("Got it!")))
                            }
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
                    //                    Text(postVM.post.text).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                    MultilineTextView(text: .constant(postVM.post.text), editable: false)
                        .frame(width: UIScreen.screenWidth - 15, height: postVM.post.text.height(withConstrainedWidth: UIScreen.screenWidth-20, font: UIFont.systemFont(ofSize: 17)) + 30)
                }
                .padding(.horizontal, 15)
                
                
                
                
                // MARK: Edit Post
                if(Auth.auth().currentUser != nil && postVM.post.author_id == Auth.auth().currentUser!.uid){ //viewer is also author
                    Button(action: {
                        self.editPostPresented.toggle()
                    }) {
                        Text("Edit").foregroundColor(AssetManager.ivyGreen)
                            .sheet(isPresented: $editPostPresented, onDismiss: {
                                //TODO: refresh on dismiss
                            }) {
                                CreatePostView(alreadyExistingPost: self.postVM.post)
                            }
                    }
                    .padding(.top, 30)
                }else{ // if not the author - show editing button
                    Button(action: {
                        self.reportPost()
                        self.showReportAlert = true
                    }) {
                        HStack{
                            Text("Report Post/its Comment Section").foregroundColor(AssetManager.ivyGreen)
                        }
                    }
                    .alert(isPresented: $showReportAlert) {
                        Alert(title: Text("Post Reported"), message: Text("The post has been reported!"), dismissButton: .default(Text("OK")))
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
                            FirebaseImage(
                                path: Utils.userPreviewImagePath(userId: Auth.auth().currentUser?.uid ?? ""),
                                placeholder: Image(systemName: "person.crop.circle.fill"),
                                width: 40,
                                height: 40,
                                shape: RoundedRectangle(cornerRadius: 20)
                            )
                            
                            
                            
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
                        .background(AssetManager.ivyLightGrey)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        if(loadInProgress){
                            LoadingSpinner().frame(width: 50, height: 50, alignment: .center)
                        }
                    }
                    .padding()
                }
                
                
                
                
                // MARK: Comment List
                if(Auth.auth().currentUser != nil){
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
                                    destination: UserProfile(uid: commentVM.comment.author_id)
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
                }else{
                    Text("Log in to see comments.").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
                }
                
                
                
                
                
            }
            
            // MARK: onAppear
        }
        .onAppear(){
            self.addToViewIds()
        }
        .onTapGesture { //hide keyboard when background tapped
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        
    }
}

