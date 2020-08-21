//
//  StudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StudentProfile: View {
    
    @ObservedObject var studentProfileVM: StudentProfileViewModel
    @State var editProfile = false
    
    // MARK: TODO: publish currently logged in student instead of passing it in
    init(_ student: Student) {
        self.studentProfileVM = StudentProfileViewModel(student: student)
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                HStack { // Profile image and quick info
                    
                    //MARK: TODO test image
                    //FirebaseImage(id: "userfiles/testID/test_flower.jpg")
                    Image("LogoGreen")
                    .resizable()
                    .frame(width: 150, height: 150)
                    
                    VStack (alignment: .leading){
                        
                        Text(studentProfileVM.student.name)
                        Text(studentProfileVM.student.degree)
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
                
                GridView()
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct StudentProfile_Previews: PreviewProvider {
    static var previews: some View {
        StudentProfile(Student(id: "HaJEXFHBNhgLrHm0EhSjgR0KXhF2", email: "test4@asd.ca", degree: "Computer Science"))
    }
}
