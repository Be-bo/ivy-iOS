//
//  UserInfoViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase

class UserInfoViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var userProfile: User //published means that this var will be listened to
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User){
        self.userProfile = user
        $userProfile.compactMap { user in
            user.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
