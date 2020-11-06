//
//  CreatePostRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Does all the backend work with Firebase
//  Uploads post, uploads image, sends notifications
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI


class CreatePostViewModel: ObservableObject{
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    private var notificationSender = NotificationSender()

    @Published var post: Post_new
    @Published var pinnedNames = [String]()
    @Published var pinnedIds = [String]()
    @Published var loadInProgress = false
    
    // Allows us to dismiss CreatePostView when shouldDismissView changes to true
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    
    // If id != nil -> editing existing Post
    init(post: Post_new?) {
        if (post != nil) { self.post = post! }
        else { self.post = Post_new() }
        self.loadPinnedNames()
    }
    
    
    func loadPinnedNames(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).getDocuments { (querSnapshot, error) in
            if let querSnap = querSnapshot{
                for doc in querSnap.documents{
                    if let id = doc.get("id") as? String, let nam = doc.get("name") as? String{
                        self.pinnedIds.append(id)
                        self.pinnedNames.append(nam)
                    }
                }
            }
        }
    }
    
    
    // send notifications to all members (if this user is org)
    func sendNotification(newPost: Bool){
        
        // Get Current user
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (docSnap, err) in
            
            if err != nil {
                print("Can't send notifications, failed to get user profile.")
                return
            }
            
            if let doc = docSnap{
                
                var thisUser = User()
                do { try thisUser = doc.data(as: User.self)! }
                catch { print("Could not load User for CreatePostVM: \(error)") }
                
                // Send notification to each member
                if (thisUser.member_ids?.count ?? 0) > 0 {
                    
                    let memberCount = thisUser.member_ids!.count
                    var index = 0
                    
                    for memberId in thisUser.member_ids! {
                        index += 1
                        
                        self.db.document(User.userPath(memberId)).getDocument { (docSnap1, error1) in
                            
                            if error1 != nil{
                                print("Failed to get member to send notification to.")
                                return
                            }
                            
                            if let doc1 = docSnap1 {
                                
                                var member = User()
                                do { try member = doc1.data(as: User.self)! }
                                catch { print("Could not load User for CreatePostVM: \(error)") }
                                
                                
                                if (newPost){ //the org was creating a new post
                                    self.notificationSender.sendPushNotification(to: member.messaging_token, title: "\(thisUser.name) added a new post.", body: self.post.text, conversationID: "")
                                    
                                } else { //the org was editing an existing post
                                    self.notificationSender.sendPushNotification(to: member.messaging_token, title: "\(thisUser.name) made changes to their post.", body: self.post.text, conversationID: "")
                                   
                                }

                                if index >= memberCount{
                                    self.shouldDismissView = true
                                }
                            }
                        }
                    }
                } else {
                    self.shouldDismissView = true
                }
            }
        }
    }
    
    
    // Upload Image to Storage
    func uploadImage(inputImage: UIImage, newPost: Bool){
        self.storageRef.child(self.post.visual)
            .putData((inputImage.jpegData(compressionQuality: 0.7)!), metadata: nil){ (error, metadata) in
            if(error != nil){
                print(error!)
            }
            self.storageRef.child(Utils.postPreviewImagePath(postId: self.post.id))
                .putData((inputImage.jpegData(compressionQuality: 0.1)!), metadata: nil){ (error1, metadata1) in
                if(error1 != nil){
                    print(error1!)
                }
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newPost: newPost)
                } else {
                   self.shouldDismissView = true
                }
            }
        }
    }
    
    
    // Upload Editted Post to Firebase
    func uploadEdittedPost(text: String, pin_name: String?, image: UIImage?){
        loadInProgress = true
        post.text = text
        
        if let pinName = pin_name{
            post.pinned_name = pinName
            post.pinned_id = self.pinnedIds[self.pinnedNames.firstIndex(of: pinName)!]
        } else {
            post.pinned_name = ""
            post.pinned_id = ""
        }
        
        
        // MARK: Visual
        if(image != nil){
            post.visual = Utils.postFullVisualPath(postId: post.id)
        } else {
            post.visual = ""
        }
        
        
        // MARK: Data Upload
        do {
            let _ = try db.document(post.getPostPath()).setData(from: post)
            
            if (image != nil){
                uploadImage(inputImage: image!, newPost: true)
            } else {
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newPost: false)
                } else {
                   self.shouldDismissView = true
                }
            }
        } catch {
            print("Couldn't edit post: \(error.localizedDescription)")
        }
    }
    
    
    func uploadNewPost(text: String, pinnedName: String?, image: UIImage?){
        loadInProgress = true
        
        // Build New Post
        post = Post_new(uni: Utils.getCampusUni(), text: text)
        post.setAuthor(
            id: Auth.auth().currentUser?.uid ?? "",
            name: Utils.getThisUserName(),
            is_org: Utils.getIsThisUserOrg())
        
        if let pinName = pinnedName{
            post.addPin(
                id: self.pinnedIds[self.pinnedNames.firstIndex(of: pinName)!],
                name: pinName
            )
        }
        
        // MARK: Visual
        if(image != nil){
            post.visual = Utils.postFullVisualPath(postId: post.id)
        }
        

        // MARK: Data Upload
        do {
            let _ = try db.document(post.getPostPath()).setData(from: post)
            
            if (image != nil){
                uploadImage(inputImage: image!, newPost: true)
            } else {
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newPost: true)
                } else {
                   self.shouldDismissView = true
                }
            }
        } catch {
            print("Couldn't create new post: \(error.localizedDescription)")
        }
    }
    
}
