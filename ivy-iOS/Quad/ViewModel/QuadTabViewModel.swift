//
//  QuadTabViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class QuadTabViewModel: ObservableObject {
    
    @Published var quadUsersVMs = [UserViewModel]()
    @Published var usersLoaded = false
    private var quadRepo : QuadRepo
    private var cancellables = Set<AnyCancellable>()

    
    // Place a listener for important values
    init(id: String) {
        self.quadRepo = QuadRepo(id: id)
        
        quadRepo.$users.map { users in
            users.map{ user in
                UserViewModel(user: user)
            }
        }
        .assign(to: \.quadUsersVMs, on: self)
        .store(in: &cancellables)
        
        quadRepo.$usersLoaded
        .assign(to: \.usersLoaded, on: self)
        .store(in: &cancellables)
    }
    
    
    // Fetch next batch if not already loading
    func fetchNextBatch() {
        if (!quadRepo.usersLoading) {
            quadRepo.loadUsers()
        }
    }

}
