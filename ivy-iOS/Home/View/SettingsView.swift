//
//  SettingsView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//


import SwiftUI
import Firebase

struct SettingsView: View {
    
    @State var uniSelection: String? = Utils.getCampusUni()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var thisUserRepo: ThisUserRepo
    
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .center){
                Text("Settings")
                    .font(.largeTitle).padding(.bottom)
                    .foregroundColor(AssetManager.textColor)
                
                
                if(Auth.auth().currentUser == nil){
                    DropDownMenu(
                        selected: $uniSelection,
                        list: StaticDomainList.available_domain_list,
                        hint: "Change Campus",
                        hintColor: AssetManager.ivyHintGreen,
                        expandedHeight: 100
                    )
                    
                    Button(action: {
                        Utils.setCampusUni(newUni: self.uniSelection ?? Utils.getCampusUni())
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Text("Save Campus").foregroundColor(AssetManager.ivyGreen)
                    }
                }else{
                    Text("Sorry, for now you have to be logged out to be able to switch campuses. :-(").foregroundColor(AssetManager.textColor)
                }
                Divider().padding(.top).padding(.bottom)
                
                Button(action: {
                    UIApplication.shared.open(URL(string: "http://theivysocialnetwork.com/static/Terms-of-Use.docx")!)
                }){
                    Text("Terms and Conditions").foregroundColor(AssetManager.ivyGreen)
                }
                
                Divider().padding(.top).padding(.bottom)
                
                
                if (thisUserRepo.userLoggedIn) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        try? Auth.auth().signOut()
                    }){
                        Text("Sign Out").foregroundColor(AssetManager.ivyGreen)
                    }
                .padding()
                }
            }
            .foregroundColor(Color.black)
        .padding()
        }
        
        
//        .alert(isPresented: $showingSignOutAlert){
//            Alert(title: Text("Signed Out"), message: Text("You've been signed out."), dismissButton: .default(Text("OK")))
//        }
    }
}


