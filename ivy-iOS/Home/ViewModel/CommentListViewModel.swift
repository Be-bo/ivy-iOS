//
//  CommentListViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class CommentListViewModel: ObservableObject{
    @Published var commentRepo: CommentRepo
    @Published var commentVMs = [CommentViewModel]()
    private var cancellables = Set<AnyCancellable>()
    
    init(uniDom: String, postId: String){
        self.commentRepo = CommentRepo(uniDom: uniDom, postId: postId)
        commentRepo.$comments.map {comments in
            comments.map{comment in
                CommentViewModel(comment: comment)
            }
        }
        .assign(to: \.commentVMs, on: self)
        .store(in: &cancellables)
    }
    
    func refresh(){
        commentRepo.refresh()
    }
}
