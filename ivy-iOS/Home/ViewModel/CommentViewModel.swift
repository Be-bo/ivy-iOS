//
//  CommentViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase

class CommentViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var comment: Comment
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(comment: Comment){
        self.comment = comment
        $comment.compactMap { comment in
            comment.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}

