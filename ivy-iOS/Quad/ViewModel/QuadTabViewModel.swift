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
    private var testNum = 0 //TODO

    
    // Place a listener for important values
    init(thisUser: User) {
        self.quadRepo = QuadRepo(thisUser: thisUser)
        
        quadRepo.$users.map { users in
            users.map{ user in
                self.testNum += 1
                print("NEW USER!!! NUM: \(self.testNum)")//TODO
                return UserViewModel(user: user)
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
            print("FETCHING NEXT BATCH") // TODO
        }
    }

}
