//
//  EventItemViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase

class EventItemViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var event: Event //published means that this var will be listened to
    @Published var thisUserGoing = false
    @Published var goingIdsWithoutThisUser = [String]()
    var id = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event){
        self.event = event
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser!.uid as? String{
            if(event.going_ids.contains(id)){
                thisUserGoing = true
                goingIdsWithoutThisUser = [String](event.going_ids)
                goingIdsWithoutThisUser.remove(at: goingIdsWithoutThisUser.firstIndex(of: id)!)
            }
        }
        $event.compactMap { event in
            event.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
    
    func addToGoing(){
        if(!event.going_ids.contains(Auth.auth().currentUser!.uid)){
            db.collection("universities").document(event.uni_domain).collection("posts").document(event.id!).updateData([
                "going_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ]){error in
                if error == nil{
                    self.thisUserGoing = true
                }
            }
        }
    }
    
    func removeFromGoing(){
        db.collection("universities").document(event.uni_domain).collection("posts").document(event.id!).updateData([
            "going_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
        ]){ error in
            if error == nil{
                self.thisUserGoing = false
            }
        }
    }
}
