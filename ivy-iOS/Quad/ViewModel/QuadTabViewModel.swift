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
    @Published var usersLoaded = false {
        didSet { //TODO: test this
            print("QuadTabVM: usersLoaded changed! val: \(usersLoaded)")
        }
    }
    private var quadRepo = QuadRepo()
    private var cancellables = Set<AnyCancellable>()

    
    init() {
        
        quadRepo.$users.map { users in
            users.map{ user in
                UserViewModel(user: user)
            }
        }
        .assign(to: \.quadUsersVMs, on: self)
        .store(in: &cancellables)
        
        // TODO: THIS IS WROOOONG
        $usersLoaded.compactMap { usersLoaded in
            self.quadRepo.usersLoaded
        }
        .assign(to: \.usersLoaded, on: self)
        .store(in: &cancellables)
    }
    
    func fetchNextBatch() {
        quadRepo.loadUsers()
    }

}
