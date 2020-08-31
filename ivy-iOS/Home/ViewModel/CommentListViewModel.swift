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
    private var selectionIndex = 300
    
    init(uniDom: String, postId: String){
        self.commentRepo = CommentRepo(uniDom: uniDom, postId: postId)
        commentRepo.$comments.map {comments in
            comments.map{comment in
                self.selectionIndex = self.selectionIndex + 1
                return CommentViewModel(comment: comment, selectionId: self.selectionIndex)
            }
        }
        .assign(to: \.commentVMs, on: self)
        .store(in: &cancellables)
    }
    
    func refresh(){
        commentRepo.refresh()
    }
}
