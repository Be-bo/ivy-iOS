//
//  CreatePostRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CreatePostRepo: ObservableObject{
    let db = Firestore.firestore()
    @Published var pinnedNames = [String]()
    @Published var pinnedIds = [String]()
    
    init() {
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
    
}
