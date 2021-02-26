//
//  CreateEventRepo.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-05.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Does all the backend work with Firebase
//  Uploads event, uploads image, sends notifications
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI


class CreateEventViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    private var notificationSender = NotificationSender()

    @Published var event: Event
    @Published var loadInProgress = false
    // Allows us to dismiss CreatePostView when shouldDismissView changes to true
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    
    // If id != nil -> editing existing Post
    init(event: Event?) {
        if (event != nil) { self.event = event! }
        else { self.event = Event() }
    }
    
    
    
    // MARK: Send notifications to all members (if this user is org)
    func sendNotification(newEvent: Bool){
        
        // Get Current user
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (docSnap, err) in
            
            if err != nil {
                print("Can't send notifications, failed to get user profile.")
                return
            }
            
            if let doc = docSnap{
                
                var thisUser = User()
                do { try thisUser = doc.data(as: User.self)! }
                catch { print("Could not load User for CreateEventVM: \(error)") }
                
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
                                catch { print("Could not load User for CreateEventVM: \(error)") }
                                
                                
                                if (newEvent){ //the org was creating a new event
                                    self.notificationSender.sendPushNotification(to: member.messaging_token, title: "\(thisUser.name) added a new event.", body: self.event.name, conversationID: "")
                                } else { //the org was editing an existing event
                                    self.notificationSender.sendPushNotification(to: member.messaging_token, title: "\(thisUser.name) made changes to their event.", body: self.event.name, conversationID: "")
                                   
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
    func uploadImage(inputImage: UIImage, newEvent: Bool){
        self.storageRef.child(self.event.visual)
            .putData((inputImage.jpegData(compressionQuality: 0.7)!), metadata: nil){ (error, metadata) in
            if(error != nil){
                print(error!)
            }
            self.storageRef.child(Utils.postPreviewImagePath(postId: self.event.id))
                .putData((inputImage.jpegData(compressionQuality: 0.1)!), metadata: nil){ (error1, metadata1) in
                if(error1 != nil){
                    print(error1!)
                }
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newEvent: newEvent)
                } else {
                   self.shouldDismissView = true
                }
            }
        }
    }
    
    
    
    // MARK: Upload Editted Post to Firebase
    func uploadEdittedEvent(text: String, eventName: String, startDate: Date, endDate: Date, link: String, location: String, image: UIImage?){
        loadInProgress = true
        
        // Set up new Parameters
        event.text = text
        event.name = eventName
        event.start_millis = Int(startDate.timeIntervalSince1970)*1000
        event.end_millis = Int(endDate.timeIntervalSince1970)*1000
        event.link = link
        event.location = location
        
        
        // Visual
        if (image != nil){
            event.visual = Utils.postFullVisualPath(postId: event.id)
        } else {
            event.visual = ""
        }
        
        
        // Data Upload
        do {
            let _ = try db.document(event.getEventPath()).setData(from: event)
            
            if (image != nil){
                uploadImage(inputImage: image!, newEvent: false)
            } else {
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newEvent: false)
                } else {
                   self.shouldDismissView = true
                }
            }
        } catch {
            print("Couldn't edit event: \(error.localizedDescription)")
        }
    }
    
    
    
    // MARK: Upload New Event
    func uploadNewEvent(text: String, eventName: String, startDate: Date, endDate: Date, link: String, location: String, image: UIImage?){
        loadInProgress = true
        
        // Build New Event
        event = Event(
            uni: Utils.getCampusUni(),
            name: eventName,
            text: text,
            link: link,
            location: location)
        
        event.setAuthor(
            id: Auth.auth().currentUser?.uid ?? "",
            name: Utils.getThisUserName(),
            is_org: Utils.getIsThisUserOrg())
        
        event.setDates(start: startDate, end: endDate)
        
        // Visual
        if(image != nil){
            event.visual = Utils.postFullVisualPath(postId: event.id)
        }
        

        // Data Upload
        do {
            let _ = try db.document(event.getEventPath()).setData(from: event)
            
            if (image != nil){
                uploadImage(inputImage: image!, newEvent: true)
            } else {
                if Utils.getIsThisUserOrg(){
                    self.sendNotification(newEvent: true)
                } else {
                   self.shouldDismissView = true
                }
            }
        } catch {
            print("Couldn't create new event: \(error.localizedDescription)")
        }
    }
}
