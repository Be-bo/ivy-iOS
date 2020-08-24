//
//  OrganizationProfileViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Combine

class OrganizationProfileViewModel: ObservableObject {
    
    @Published var organization: User
    
    init(organization: User) {
        self.organization = organization
    }
    
}
