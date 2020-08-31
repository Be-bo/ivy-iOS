//
//  StudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct StudentProfile: View {
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var uniInfo = UniInfo()
    var uid = ""
    @State var editProfile = false
    @State var selection : Int? = nil
    @State var userPicUrl = ""
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    
    
    init(uid: String) {
        self.profileViewModel = ProfileViewModel(uid: uid)
        self.uid = uid
    }
    
    var body: some View {
        
        ScrollView() {
            VStack (alignment: .leading) {
                
                // MARK: Header
                HStack {
                    
                    // MARK: Profile Image
                    WebImage(url: URL(string: userPicUrl))
                        .resizable()
                        .placeholder(Image(systemName: "person.crop.circle.fill"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .onAppear(){
                            self.userPicUrl = ""
                            let storage = Storage.storage().reference()
                            storage.child(Utils.userProfileImagePath(userId: self.uid)).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading org profile image.")
                                    return
                                }
                                self.userPicUrl = "\(url!)"
                            }
                    }.padding(.trailing, 10)
                    
                    // MARK: Text Info
                    VStack (alignment: .leading){
                        Text(profileViewModel.userInfoVM.userProfile.name).padding(.bottom, 10)
                        Text(profileViewModel.userInfoVM.userProfile.degree).padding(.bottom, 10)
                        
                        // If this is thisUserProfile, then show edit button
                        if Auth.auth().currentUser != nil && profileViewModel.userInfoVM.userProfile.id ?? "" == Auth.auth().currentUser!.uid {
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile, onDismiss: { //refresh pic and posts
                                    let storage = Storage.storage().reference()
                                    storage.child(self.profileViewModel.userInfoVM.userProfile.profileImagePath()).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading org profile image.")
                                            return
                                        }
                                        self.userPicUrl = "\(url!)"
                                    }
                                }){
                                    //                                    EditStudentProfile(thisUserRepo: self.userRepo as! ThisUserRepo)
                                    EditOrganizationProfile(userProfile: self.profileViewModel.userInfoVM.userProfile, nameInput: self.profileViewModel.userInfoVM.userProfile.name)
                                }
                            }.padding(.bottom, 10)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                
                // MARK: Post & Events
                
                ZStack{
                    VStack(alignment: .center){
                        // MARK: EVENTS
                        if (self.profileViewModel.userEventVMs.count > 0) {
                            HStack {
                                Text("Events")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.profileViewModel.userEventVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { eventVM in
                                ProfileEventItemView(eventVM: eventVM)
                            }
                            //}
                        }
                        
                        // MARK: POSTS
                        if (self.profileViewModel.userPostVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.profileViewModel.userPostVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { postVM in
                                ProfilePostItemView(postVM: postVM)
                            }
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
                    .padding(.horizontal, 10)
                }
                LoadingSpinner().frame(width: UIScreen.screenWidth, height: 5, alignment: .center).hidden()   // TODO: quick and dirty
                
            }
            .padding(.horizontal)
            .onAppear(){
                self.userPicUrl = "" //force reload
            }
        }
    }
}

