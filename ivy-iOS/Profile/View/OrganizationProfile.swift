//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct OrganizationProfile: View {
    let db = Firestore.firestore()
    var uid = ""
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var uniInfo = UniInfo()
    @State var userPicUrl = ""
    @State var editProfile = false
    @State var seeMemberRequests = false
    @State var selection : Int? = nil
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    
    
    init(uid: String) {
        self.uid = uid
        self.profileViewModel = ProfileViewModel(uid: uid)
    }
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                // MARK: Header
                HStack {
                    
                    // MARK: Profile Image
                    ZStack{
                        WebImage(url: URL(string: userPicUrl))
                            .resizable()
                            .placeholder(Image(systemName: "person.crop.circle.fill"))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                //                                        print("img: ",Utils.userProfileImagePath(userId: self.profileViewModel.userInfoVM.userProfile.id ?? ""))
                                storage.child(Utils.userProfileImagePath(userId: self.uid)).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading org profile image.")
                                        return
                                    }
                                    self.userPicUrl = "\(url!)"
                                }
                        }.padding(.horizontal, 10)
                    }
                    
                    
                    
                    
                    // MARK: Profile Info
                    VStack (alignment: .leading){
                        Text(self.profileViewModel.userInfoVM.userProfile.name).padding(.bottom, 10)
                        if(profileViewModel.userInfoVM.userProfile.member_ids.count == 1){
                            Text("\(profileViewModel.userInfoVM.userProfile.member_ids.count) Member").padding(.bottom, 10)
                        }else{
                            Text("\(profileViewModel.userInfoVM.userProfile.member_ids.count) Members").padding(.bottom, 10)
                        }
                        
                        if Auth.auth().currentUser != nil && profileViewModel.userInfoVM.userProfile.id ?? "" == Auth.auth().currentUser!.uid { // check if this is 3rd person user
                            
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile, onDismiss: { //refresh profile pic
                                    let storage = Storage.storage().reference()
                                    storage.child(self.profileViewModel.userInfoVM.userProfile.profileImagePath()).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading org profile image.")
                                            return
                                        }
                                        self.userPicUrl = "\(url!)"
                                    }
                                }){
                                    EditOrganizationProfile(userProfile: self.profileViewModel.userInfoVM.userProfile, nameInput: self.profileViewModel.userInfoVM.userProfile.name)
                                }
                            }.padding(.bottom, 10)
                            
                        }
                        else {
                            // MARK: Membership Buttons
                            if Auth.auth().currentUser != nil && profileViewModel.userInfoVM.userProfile.id != Auth.auth().currentUser!.uid{ //user had to be logged in and not be viewing themselves 3rd party
                                
                                // MARK: Student Requesting Buttons
                                if(!profileViewModel.userInfoVM.userProfile.member_ids.contains(Auth.auth().currentUser!.uid)){ //viewing user not a member
                                    if(profileViewModel.userInfoVM.userProfile.request_ids.contains(Auth.auth().currentUser!.uid)){ //viewing user already requested membership
                                        Button(action: {
                                            self.cancelRequest()
                                        }){
                                            Text("Cancel Join Reqest")
                                        }
                                    }else{ //neither a mem nor a req -> can request membership
                                        Button(action: {
                                            self.requestMembership()
                                        }){
                                            Text("Request Membership")
                                        }
                                    }
                                }else{ //viewing user is a member
                                    Button(action: {
                                        self.leaveOrganization()
                                    }){
                                        Text("Leave Organization")
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                
                // MARK: Members
                if(profileViewModel.userInfoVM.userProfile.member_ids.count > 0){
                    MemberListRow(memberIds: profileViewModel.userInfoVM.userProfile.member_ids, orgId: profileViewModel.userInfoVM.userProfile.id ?? "", userIsOrg: false).padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Member Requests
                if(profileViewModel.userInfoVM.userProfile.request_ids.count > 0 && Auth.auth().currentUser != nil && profileViewModel.userInfoVM.userProfile.id == Auth.auth().currentUser!.uid){
                    MemberListRow(memberIds: profileViewModel.userInfoVM.userProfile.request_ids, orgId: profileViewModel.userInfoVM.userProfile.id ?? "", titleText: "Member Requests", userIsOrg: false).padding(.top, 20).padding(.bottom, 20)
                }
                
                
                
                // MARK: Posts
                
                ZStack{
                    
                    VStack {
                        // MARK: EVENTS
                        if (profileViewModel.userEventVMs.count > 0) {
                            HStack {
                                Text("Events")
                                Spacer()
                            }.padding(.horizontal, 10)
                            
                            GridView(
                                cells: self.profileViewModel.userEventVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { eventVM in
                                ProfileEventItemView(eventVM: eventVM)
                            }.padding(.horizontal, 10)
                            //}
                        }
                        
                        // MARK: POSTS
                        if (profileViewModel.userPostVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }.padding(.horizontal, 10)
                            
                            GridView(
                                cells: self.profileViewModel.userPostVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { postVM in
                                ProfilePostItemView(postVM: postVM)
                            }
                            .padding(.horizontal, 10)
                            //}
                        }
                            
                        else {
                            Spacer()
                            Text("No Posts or Events yet!")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(alignment: .center)
                        }
                    }
                }
                
                LoadingSpinner().frame(width: UIScreen.screenWidth, height: 5).hidden()   // TODO: quick and dirty
            }
            .padding(.horizontal)
        }
    }
    
    
    
    
    
    
    
    
    // MARK: Membership Functions
    func requestMembership(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(profileViewModel.userInfoVM.userProfile.id ?? "").updateData([
                "request_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func cancelRequest(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(profileViewModel.userInfoVM.userProfile.id ?? "").updateData([
                "request_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func leaveOrganization(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(profileViewModel.userInfoVM.userProfile.id ?? "").updateData([
                "member_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
}






