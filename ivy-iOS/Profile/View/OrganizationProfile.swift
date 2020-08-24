//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


struct OrganizationProfile: View {
    
    @ObservedObject var postListVM: PostListViewModel
    @State var editProfile = false
    @State var seeMemberRequests = false
    // MARK: Robert
//    var organization: Organization
    var organization: User
    
    // MARK: Robert
//    init(organization: Organization) {
//        self.organization = organization
//        self.postListVM = PostListViewModel(
//            user_id: organization.id ?? "",
//            uni_domain: organization.uni_domain ?? "",
//            limit: Constant.PROFILE_POST_LIMIT_ORG
//        )
//    }
    
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
                        
                        Text(organization.name)
                        Text("Members")
                            .padding(.bottom)
                        
                        Button(action: {
                            self.seeMemberRequests.toggle()
                        }){
                            Text("Member Requests").sheet(isPresented: $seeMemberRequests){
                                SeeAllUsers()
                            }
                        }
                        
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
                
                SeeMembers()
                
                
                Text("Posts")
                //GridView()
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

//struct OrganizationProfile_Previews: PreviewProvider {
//    static var previews: some View {
//        OrganizationProfile(organization: Organization(id: "HaJEXFHBNhgLrHm0EhSjgR0KXhF2", email: "test4@asd.ca", is_club: false))
//    }
//}

/* SubViews */

struct SeeMembers: View {
    var body: some View {
        VStack {
            Text("Members")
            
            ScrollView {
                HStack {
                    ForEach(1...5, id: \.self) {_ in
                        Image("LogoGreen")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
            }
        }
    }
}
