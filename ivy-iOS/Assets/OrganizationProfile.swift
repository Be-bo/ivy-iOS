//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


struct OrganizationProfile: View {
    
    @ObservedObject var orgProfileVM: OrganizationProfileViewModel
    @State var editProfile = false
    @State var seeMemberRequests = false
    
    // MARK: TODO: publish currently logged in student instead of passing it in
    init(_ organization: Organization) {
        self.orgProfileVM = OrganizationProfileViewModel(organization: organization)
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
                        
                        Text(orgProfileVM.organization.name)
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
                GridView()
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct OrganizationProfile_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationProfile(Organization(id: "HaJEXFHBNhgLrHm0EhSjgR0KXhF2", email: "test4@asd.ca", is_club: false))
    }
}

/* SubViews */

struct SeeMembers: View {
    var body: some View {
        VStack {
            Text("Members")
            
            ScrollView {
                HStack {
                    Image("LogoGreen")
                    .resizable()
                    .frame(width: 150, height: 150)
                    
                    Spacer()
                }
            }
        }
    }
}
