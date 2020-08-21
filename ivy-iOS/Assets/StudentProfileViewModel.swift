//
//  StudentProfileViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Combine

class StudentProfileViewModel: ObservableObject {
    
    @Published var student: Student
    
    init(student: Student) {
        self.student = student
    }
    
}
