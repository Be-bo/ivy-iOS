//
//  UserViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase


class UserViewModel: ObservableObject, Identifiable {
    
    @Published var user: User
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User) {
        self.user = user
        $user.compactMap { user in
            user.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}

