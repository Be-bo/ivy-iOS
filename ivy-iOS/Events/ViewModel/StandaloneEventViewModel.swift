//
//  StandaloneEventViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-26.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase

class StandaloneEventViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var event = Event()
    @Published var eventId: String
    @Published var thisUserGoing = false
    @Published var goingIdsWithoutThisUser = [String]()
    var id = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(eventId: String){
        self.eventId = eventId
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(eventId).getDocument{(docsnap, error) in
            if error != nil{
                print("Failed to load standalone event for model.")
            }
            if let doc = docsnap {
                do { try self.event = doc.data(as: Event.self)! }
                catch { print("Could not load standalone Event: \(error)") }
            }
        }
    }
    
    func addToGoing(){
        if(!event.going_ids.contains(Auth.auth().currentUser!.uid)){
            db.collection("universities").document(event.uni_domain).collection("posts").document(event.id).updateData([
                "going_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ]){error in
                if error == nil{
                    self.thisUserGoing = true
                }
            }
        }
    }
    
    func removeFromGoing(){
        db.collection("universities").document(event.uni_domain).collection("posts").document(event.id).updateData([
            "going_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
        ]){ error in
            if error == nil{
                self.thisUserGoing = false
            }
        }
    }
}
