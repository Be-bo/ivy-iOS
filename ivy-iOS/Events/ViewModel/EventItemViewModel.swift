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
    @Published var thisUserGoing = false //need this for the going/not going button, it doesn't work when using indexOf method
    var id = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event){
        self.event = event
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid{
            if(event.going_ids.contains(id)){
                thisUserGoing = true
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
            db.document(Event.eventPath(event.id)).updateData([
                "going_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ]){error in
                if error != nil{
                    print(error ?? "")
                    return
                }
                self.thisUserGoing = true
                self.event.going_ids.append(Auth.auth().currentUser!.uid)
            }
        }
    }
    
    func removeFromGoing(){
        if(event.going_ids.contains(Auth.auth().currentUser!.uid)){
            db.document(Event.eventPath(event.id)).updateData([
                "going_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ]){ error in
                if error != nil{
                    print(error ?? "")
                    return
                }
                self.thisUserGoing = false
                self.event.going_ids.remove(at: self.event.going_ids.firstIndex(of: Auth.auth().currentUser!.uid)!)
            }
        }
    }
}
