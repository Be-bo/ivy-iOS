//
//  SeeMembers.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase

struct MemberListRow: View {
    var thisUserIsOrg: Bool
    let db = Firestore.firestore()
    @State var memberIds = [String]()
    @State var orgId: String
    @State var titleText = "Members"
    @State var userIsOrg: Bool
    @State var showingRequestAlert = false
    @State var selection: Int? = nil
    
    // MARK: Membership Functions
    func acceptMembership(idToAccept: String){
        db.collection("users").document(orgId).updateData([
            "member_ids": FieldValue.arrayUnion([idToAccept]),
            "request_ids": FieldValue.arrayRemove([idToAccept])
        ]){error in
            if error == nil{
                self.memberIds.remove(at: self.memberIds.firstIndex(of: idToAccept)!)
            }
        }
        
    }
    
    func rejectMembership(idToReject: String){
        db.collection("users").document(orgId).updateData([
            "request_ids": FieldValue.arrayRemove([idToReject])
        ]){error in
            if error == nil{
                self.memberIds.remove(at: self.memberIds.firstIndex(of: idToReject)!)
            }
        }
    }
    
    
    
    
    var body: some View {
        VStack {
            HStack{
                Text(self.titleText)
                Spacer()
            }
            ScrollView(.horizontal){
                HStack{
                    ForEach(memberIds, id: \.self) { currentId in
                        VStack(alignment: .center){
                            
                            // MARK: Preview Image Button
                            Button(action:{
                                self.selection = 1
                            }){ //circle profile pic button -> transition to profile
                                ZStack{
                                    PersonCircleView(personId: currentId)
                                    if(self.userIsOrg){
                                        NavigationLink(
                                            destination: OrganizationProfile(
                                                userRepo: UserRepo(userid: currentId),
                                                uni_domain: Utils.getCampusUni(),
                                                user_id: currentId, thisUserIsOrg: self.thisUserIsOrg
                                            ).navigationBarTitle("Profile"),
                                            tag: 1,
                                            selection: self.$selection) {
                                                EmptyView()
                                        }
                                    }else{
                                        NavigationLink(
                                            destination: StudentProfile(
                                                userRepo: UserRepo(userid: currentId),
                                                uni_domain: Utils.getCampusUni(),
                                                user_id: currentId, thisUserIsOrg: self.thisUserIsOrg
                                            ).navigationBarTitle("Profile"),
                                            tag: 1,
                                            selection: self.$selection) {
                                                EmptyView()
                                        }
                                    }
                                    
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            // MARK: Member Request Button
                            if(self.titleText == "Member Requests"){
                                Button(action:{
                                    self.showingRequestAlert.toggle()
                                }){ //membership text (to decide acceptance/rejection)
                                    Text("Decide").multilineTextAlignment(.center).foregroundColor(AssetManager.ivyGreen)
                                }
                                .alert(isPresented: self.$showingRequestAlert){
                                    Alert(title: Text("Membership Request"), message: Text("This user wants to join your organization."), primaryButton: Alert.Button.default(Text("Accept"), action: {
                                        self.acceptMembership(idToAccept: currentId)
                                    }), secondaryButton: Alert.Button.cancel(Text("Reject"), action: {
                                        self.rejectMembership(idToReject: currentId)
                                    })
                                    )
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
}
