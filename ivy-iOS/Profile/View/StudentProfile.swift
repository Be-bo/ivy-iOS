//
//  StudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StudentProfile: View {
    
    @ObservedObject var postListVM : PostListViewModel
    @State var editProfile = false
    // MARK: Robert
//    var student: Student
    var student: User
    
    // MARK: Robert
    // MARK: TODO: publish currently logged in student instead of passing it in
//    init(student: Student) {
//        self.student = student
//        self.postListVM = PostListViewModel(
//            user_id: student.id ?? "",
//            uni_domain: student.uni_domain ?? "",
//            limit: Constant.PROFILE_POST_LIMIT_STUDENT
//        )
//    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                HStack { // Profile image and quick info
                    
                    //MARK: TODO test image
                    FirebaseImage(path: student.profileImagePath())
                    Image("LogoGreen")
                    .resizable()
                    .frame(width: 150, height: 150)
                    
                    VStack (alignment: .leading){
                        
                        Text(student.name)
                        Text(student.degree)
                            .padding(.bottom)
                        
                        
                        Button(action: {
                            self.editProfile.toggle()
                        }){
                            Text("Edit").sheet(isPresented: $editProfile){
                                EditStudentProfile()
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                Text("Posts")
                
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: Robert
//struct StudentProfile_Previews: PreviewProvider {
//    static var previews: some View {
//        StudentProfile(student: Student(id: "HaJEXFHBNhgLrHm0EhSjgR0KXhF2", email: "test4@asd.ca", degree: "Computer Science"))
//    }
//}
