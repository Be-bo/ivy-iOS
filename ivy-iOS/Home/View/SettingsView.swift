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
    @ObservedObject var uniInfo = UniInfo()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var thisUserRepo: ThisUserRepo
    
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .center){
                Text("Settings").font(.largeTitle).padding(.bottom, 10)
                
                DropDownMenu(
                    selected: $uniSelection,
                    list: StaticDomainList.available_domain_list,
                    hint: "Change Campus",
                    hintColor: AssetManager.ivyHintGreen,
                    background: Color.white,
                    expandedHeight: 200
                )
                
                Button(action: {
                    Utils.setCampusUni(newUni: self.uniSelection ?? Utils.getCampusUni())
                    self.uniInfo.uniLogoUrl = Utils.uniLogoPath()
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("Save Campus").foregroundColor(AssetManager.ivyGreen)
                }
                Divider().padding(.bottom).padding(.top)
                
                if (thisUserRepo.userLoggedIn) {
                    Button(action: {
                        //TODO: reset all tabs
                        self.presentationMode.wrappedValue.dismiss()
                        try? Auth.auth().signOut()
                    }){
                        Text("Sign Out").foregroundColor(AssetManager.ivyGreen)
                    }
                }
            }
        .padding()
        }
        
        
//        .alert(isPresented: $showingSignOutAlert){
//            Alert(title: Text("Signed Out"), message: Text("You've been signed out."), dismissButton: .default(Text("OK")))
//        }
    }
}


