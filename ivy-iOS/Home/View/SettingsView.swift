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
                
                Button(action: {
                    try? Auth.auth().signOut()
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("Sign Out").foregroundColor(AssetManager.ivyGreen)
                }
            }
        .padding()
        }
        
        
//        .alert(isPresented: $showingSignOutAlert){
//            Alert(title: Text("Signed Out"), message: Text("You've been signed out."), dismissButton: .default(Text("OK")))
//        }
    }
}


