//
//  CommentRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentRepo: ObservableObject{
    let creationMillis = Utils.getCurrentTimeInMillis()
    let db = Firestore.firestore()
    @Published var comments = [Comment]()
    var uniDomain = ""
    var postId = ""
    
    init(uniDom: String, postId: String) {
        self.uniDomain = uniDom
        self.postId = postId
        self.loadComments()
    }
    
    func loadComments(){
        db.collection("universities").document(self.uniDomain).collection("posts").document(self.postId).collection("comments").order(by: "creation_millis", descending: true).getDocuments{ (querySnapshot, error) in
            if error != nil{
                print("Error loading post comments.")
                return
            }
            if let querySnap = querySnapshot{
                for currentDoc in querySnap.documents{
                    let newComment = Comment()
                    newComment.docToObject(doc: currentDoc)
                    self.comments.append(newComment)
                }
            }
        }
    }
    
    func refresh(){
        db.collection("universities").document(self.uniDomain).collection("posts").document(self.postId).collection("comments").whereField("creation_millis", isGreaterThan: creationMillis).order(by: "creation_millis").getDocuments{ (querySnapshot, error) in
            if error != nil{
                print("Error loading post comments.")
                return
            }
            if let querySnap = querySnapshot{
                for currentDoc in querySnap.documents{
                    let newComment = Comment()
                    var dontAdd = false
                    newComment.docToObject(doc: currentDoc)
                    for currentComment in self.comments{
                        if(currentComment.id == newComment.id){
                            dontAdd = true
                            break
                        }
                    }
                    if(!dontAdd){
                        self.comments.insert(newComment, at: 0)
                    }
                }
            }
        }
    }
}
